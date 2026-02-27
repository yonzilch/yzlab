{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.dn42;
  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    literalExpression
    ;

  # ── peer submodule ────────────────────────────────────────────────────────
  peerSubmodule = types.submodule {
    options = {
      # WireGuard side
      wg = {
        listenPort = mkOption {
          type = types.port;
          description = "WireGuard listen port for this peer.";
        };
        publicKey = mkOption {
          type = types.str;
          description = "WireGuard public key of the remote peer.";
        };
        endpoint = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Optional WireGuard endpoint (host:port).";
        };
        dynamicEndpointRefreshSeconds = mkOption {
          type = types.int;
          default = 5;
          description = "How often to refresh a dynamic endpoint (seconds).";
        };
        linkLocal = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Local IPv6 link-local address for this interface (e.g. fe80::67b3/64). Null to skip.";
        };
        remoteV4 = mkOption {
          type = types.str;
          default = null;
          description = "Remote IPv4 tunnel address, no prefix (e.g. 172.20.0.2).";
        };
        remoteV6 = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Remote IPv6 ULA address, no prefix (e.g. fd00::2). Null to skip.";
        };
      };

      # BGP side
      bgp = {
        enableV4 = mkOption {
          type = types.bool;
          default = true;
          description = "Enable IPv4 BGP session for this peer.";
        };
        enableV6 = mkOption {
          type = types.bool;
          default = true;
          description = "Enable IPv6 BGP session for this peer.";
        };
        enableMpBGP = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Enable MP-BGP IPv4 over IPv6 (Extended Next Hop).
            When enabled:
              - No IPv4 BGP session is created
              - IPv4 routes are exchanged over the IPv6 BGP session
              - Requires enableV6 = true
              - Does NOT require IPv4 address on the tunnel interface
          '';
        };
        remoteAs = mkOption {
          type = types.int;
          description = "Remote AS number.";
        };
        neighborLinkLocal = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Remote link-local IPv6 for BGP session (e.g. fe80::1). If null, falls back to wg.remoteV6.";
        };
      };
    };
  };
in {
  # ── option declarations ───────────────────────────────────────────────────
  options.services.dn42 = {
    enable = mkEnableOption "DN42 (WireGuard + BIRD2 BGP) node";

    privateKeyFile = mkOption {
      type = types.path;
      description = ''
        Path to the SOPS-decrypted WireGuard private key file.
        Typically set to `config.sops.secrets."<name>".path`.
      '';
      example = "/run/secrets/wg-private-key";
    };

    asn = mkOption {
      type = types.int;
      description = "Your DN42 / BGP AS number (e.g. 4242420000).";
    };

    ownIP = mkOption {
      type = types.str;
      description = "Your primary DN42 IPv4 router-id / loopback address (e.g. 172.20.0.1).";
    };

    ownIPv6 = mkOption {
      type = types.str;
      description = "Your primary DN42 IPv6 ULA address (e.g. fd00::1).";
    };

    ownNet = mkOption {
      type = types.str;
      description = "Your DN42 IPv4 prefix (e.g. 172.20.0.0/27).";
    };

    ownNetv6 = mkOption {
      type = types.str;
      description = "Your DN42 IPv6 prefix (e.g. fd00::/48).";
    };

    bgpTemplate = mkOption {
      type = types.lines;
      description = ''
        BIRD2 BGP template for DN42 peers.
        This defines import/export filters and common BGP behavior.
      '';
      default = ''
        template bgp dnpeers {
          local as OWNAS;
          path metric 1;

          ipv4 {
            import filter {
              if is_valid_network() && !is_self_net() then {
                if (roa_check(dn42_roa, net, bgp_path.last) != ROA_VALID) then {
                  print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
                  reject;
                } else accept;
              } else reject;
            };

            export filter {
              if is_valid_network() && source ~ [RTS_STATIC, RTS_BGP] then accept;
              else reject;
            };

            import limit 9000 action block;
          };

          ipv6 {
            import filter {
              if is_valid_network_v6() && !is_self_net_v6() then {
                if (roa_check(dn42_roa_v6, net, bgp_path.last) != ROA_VALID) then {
                  print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
                  reject;
                } else accept;
              } else reject;
            };

            export filter {
              if is_valid_network_v6() && source ~ [RTS_STATIC, RTS_BGP] then accept;
              else reject;
            };

            import limit 9000 action block;
          };
        }
      '';
    };

    extraBirdConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra BIRD2 configuration appended after generated config.";
    };

    peers = mkOption {
      type = types.attrsOf peerSubmodule;
      default = {};
      description = "Attribute set of DN42 peers; each key becomes an interface / BGP session name.";
      example = literalExpression ''
        {
          example_peer = {
            wg = {
              listenPort = 12345;
              publicKey  = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
              endpoint   = "peer.example.com:12345";
              linkLocal  = "fe80::1/64";
              remoteV4   = "172.20.0.2/32";
              remoteV6   = "fd00::2/128";
            };
            bgp = {
              remoteAs   = 4242420000;
              neighborLinkLocal = fe80::2;
            };
          };
        }
      '';
    };
  };

  # ── implementation ────────────────────────────────────────────────────────
  config = mkIf cfg.enable {
    assertions = lib.flatten (
      lib.mapAttrsToList (_: peer: [
        {
          assertion = !(peer.bgp.enableMpBGP && !peer.bgp.enableV6);
          message = "enableMpBGP requires bgp.enableV6 = true";
        }
        {
          assertion = !(peer.bgp.enableMpBGP && peer.bgp.enableV4);
          message = "enableMpBGP is incompatible with bgp.enableV4 (no separate IPv4 session)";
        }
      ])
      cfg.peers
    );

    # ── WireGuard interfaces (one per peer) ───────────────────────────────
    networking.wireguard.interfaces = lib.listToAttrs (
      lib.mapAttrsToList (
        peerName: peer: let
          ifName = "dn42-${peerName}";
        in
          lib.nameValuePair ifName {
            listenPort = peer.wg.listenPort;
            privateKeyFile = cfg.privateKeyFile;
            allowedIPsAsRoutes = false;
            peers = [
              {
                inherit (peer.wg) publicKey;
                allowedIPs = [
                  "10.0.0.0/8"
                  "172.20.0.0/14"
                  "172.31.0.0/16"
                  "fd00::/8"
                  "fe80::/64"
                ];
                endpoint = lib.mkIf (peer.wg.endpoint != null) peer.wg.endpoint;
                dynamicEndpointRefreshSeconds = peer.wg.dynamicEndpointRefreshSeconds;
              }
            ];
            postSetup = ''
              ${lib.optionalString (
                peer.bgp.enableV6 && peer.wg.linkLocal != null
              ) "${pkgs.iproute2}/bin/ip -6 addr add ${peer.wg.linkLocal} dev ${ifName}"}
              ${lib.optionalString (
                peer.bgp.enableV4 && !peer.bgp.enableMpBGP && peer.wg.remoteV4 != null
              ) "${pkgs.iproute2}/bin/ip addr add ${cfg.ownIP}/32 peer ${peer.wg.remoteV4}/32 dev ${ifName}"}
              ${
                lib.optionalString (peer.bgp.enableV6 && peer.wg.remoteV6 != null)
                "${pkgs.iproute2}/bin/ip -6 addr add ${cfg.ownIPv6}/128 peer ${peer.wg.remoteV6}/128 dev ${ifName}"
              }
            '';
          }
      )
      cfg.peers
    );
    # ── firewall ──────────────────────────────────────────────────────────
    networking.firewall = {
      allowedTCPPorts = [179]; # BGP
      allowedUDPPorts = lib.mapAttrsToList (_: peer: peer.wg.listenPort) cfg.peers;
    };

    # ── BIRD2 ─────────────────────────────────────────────────────────────
    services.bird = {
      enable = true;
      package = pkgs.bird2;
      checkConfig = false;
      config = ''
        ################################################
        #               Variable header                #
        ################################################
        define OWNAS    = ${toString cfg.asn};
        define OWNIP    = ${cfg.ownIP};
        define OWNIPv6  = ${cfg.ownIPv6};
        define OWNNET   = ${cfg.ownNet};
        define OWNNETv6 = ${cfg.ownNetv6};
        define OWNNETSET   = [${
          lib.concatStringsSep ", " [
            "${cfg.ownNet}+"
          ]
        }];
        define OWNNETSETv6 = [${
          lib.concatStringsSep ", " [
            "${cfg.ownNetv6}+"
          ]
        }];
        ################################################
        #                 Header end                   #
        ################################################

        router id OWNIP;

        protocol device { scan time 10; }

        function is_self_net() -> bool {
          return net ~ OWNNETSET;
        }
        function is_self_net_v6() -> bool {
          return net ~ OWNNETSETv6;
        }
        function is_valid_network() -> bool {
          return net ~ [
            172.20.0.0/14{21,29},
            172.20.0.0/24{28,32},
            172.21.0.0/24{28,32},
            172.22.0.0/24{28,32},
            172.23.0.0/24{28,32},
            172.31.0.0/16+,
            10.100.0.0/14+,
            10.127.0.0/16+,
            10.0.0.0/8{15,24}
          ];
        }
        function is_valid_network_v6() -> bool {
          return net ~ [
            fd00::/8{44,64}
          ];
        }

        roa4 table dn42_roa;
        roa6 table dn42_roa_v6;

        protocol static {
          roa4 { table dn42_roa; };
          include "/etc/bird/roa_dn42.conf";
        };
        protocol static {
          roa6 { table dn42_roa_v6; };
          include "/etc/bird/roa_dn42_v6.conf";
        };

        protocol kernel {
          scan time 20;
          ipv6 {
            import none;
            export filter {
              if source = RTS_STATIC then reject;
              krt_prefsrc = OWNIPv6;
              accept;
            };
          };
        };

        protocol kernel {
          scan time 20;
          ipv4 {
            import none;
            export filter {
              if source = RTS_STATIC then reject;
              krt_prefsrc = OWNIP;
              accept;
            };
          };
        }

        protocol static {
          route OWNNET reject;
          ipv4 { import all; export none; };
        }

        protocol static {
          route OWNNETv6 reject;
          ipv6 { import all; export none; };
        }

        ${cfg.bgpTemplate}

        include "/etc/bird/peers/*";

        ${cfg.extraBirdConfig}
      '';
    };

    # ── BIRD peer config files (/etc/bird/peers/<name>.conf) ─────────────
    environment.etc =
      lib.mapAttrs' (
        peerName: peer:
          lib.nameValuePair "bird/peers/${peerName}.conf" {
            user = "bird";
            group = "bird";
            mode = "0400";
            text = let
              neighborV6 =
                if peer.bgp.neighborLinkLocal != null
                then peer.bgp.neighborLinkLocal
                else peer.wg.remoteV6;
            in
              lib.concatStringsSep "\n" (
                lib.optional (peer.bgp.enableV4 && !peer.bgp.enableMpBGP) ''
                  protocol bgp dn42_${peerName}_v4 from dnpeers {
                    neighbor ${peer.wg.remoteV4} as ${toString peer.bgp.remoteAs};
                    direct;
                    ipv6 { import none; export none; };
                  };
                ''
                ++ lib.optional peer.bgp.enableV6 (
                  if peer.bgp.enableMpBGP
                  then ''
                    protocol bgp dn42_${peerName}_mpbgp from dnpeers {
                      enable extended messages on;
                      neighbor ${neighborV6} % 'dn42-${peerName}' as ${toString peer.bgp.remoteAs};
                      direct;

                      ipv4 {
                        extended next hop on;
                      };

                      ipv6 {
                        import none;
                        export none;
                      };
                    };
                  ''
                  else ''
                    protocol bgp dn42_${peerName}_v6 from dnpeers {
                      neighbor ${neighborV6} % 'dn42-${peerName}' as ${toString peer.bgp.remoteAs};
                      direct;
                      ipv4 { import none; export none; };
                    };
                  ''
                )
              );
          }
      )
      cfg.peers;

    # ── systemd: ROA init + watcher + timer ───────────────────────────────
    systemd = {
      paths.bird-peers-watch = {
        description = "Watch /etc/bird/peers for changes";
        pathConfig = {
          PathChanged = "/etc/bird/peers";
          PathModified = "/etc/bird/peers";
          Unit = "bird-reload.service";
        };
        wantedBy = ["multi-user.target"];
      };

      timers.dn42-roa = {
        description = "Hourly DN42 ROA table refresh";
        timerConfig = {
          OnCalendar = "hourly";
          Unit = "dn42-roa.service";
        };
        wantedBy = ["timers.target"];
      };

      services = {
        init-roa = {
          description = "Initialize DN42 ROA tables before BIRD starts";
          before = ["bird.service"];
          wantedBy = ["bird.service"];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = let
              script = pkgs.writeShellScriptBin "init-roa" ''
                mkdir -p /etc/bird/
                ${pkgs.curl}/bin/curl -sfSLR {-o,-z}/etc/bird/roa_dn42_v6.conf \
                  https://dn42.burble.com/roa/dn42_roa_bird2_6.conf
                ${pkgs.curl}/bin/curl -sfSLR {-o,-z}/etc/bird/roa_dn42.conf \
                  https://dn42.burble.com/roa/dn42_roa_bird2_4.conf
              '';
            in "${script}/bin/init-roa";
          };
        };

        bird-reload = {
          description = "Reload BIRD when peers config changes";
          after = [
            "network.target"
            "bird.service"
          ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.bird2}/bin/birdc configure";
          };
        };

        dn42-roa = {
          description = "DN42 ROA Updater";
          after = [
            "network.target"
            "bird.service"
          ];
          serviceConfig = let
            script = pkgs.writeShellScriptBin "update-roa" ''
              mkdir -p /etc/bird/
              ${pkgs.curl}/bin/curl -sfSLR {-o,-z}/etc/bird/roa_dn42_v6.conf \
                https://dn42.burble.com/roa/dn42_roa_bird2_6.conf
              ${pkgs.curl}/bin/curl -sfSLR {-o,-z}/etc/bird/roa_dn42.conf \
                https://dn42.burble.com/roa/dn42_roa_bird2_4.conf
              ${pkgs.bird2}/bin/birdc configure
              ${pkgs.bird2}/bin/birdc reload in all
            '';
          in {
            Type = "oneshot";
            ExecStart = "${script}/bin/update-roa";
          };
        };
      };
    };
  };
}
