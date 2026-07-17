{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.xl;
  inherit (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;
in
{
  options.services.xl = {
    enable = mkEnableOption "xl";

    configDir = mkOption {
      type = types.path;
      default = "/etc/xl/config.json";
      description = "Directory used for xl config.";
    };
    enableXdp = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable XDP
        (An advanced technology that could reduce latency and be more safer for usecase.)
      '';
    };
    port = mkOption {
      type = types.port;
      default = 443;
      description = "The port for xl should be opened.";
    };
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to open the xl port in the firewall";
    };
    user = mkOption {
      type = types.str;
      default = "xl";
      description = "The user xl should run as.";
    };
    group = mkOption {
      type = types.str;
      default = "xl";
      description = "The group xl should run as.";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (_final: prev: {
        xl = prev.callPackage ../../pkgs/xl/default.nix { };
      })
    ];

    systemd.services.xl = {
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "nss-lookup.target"
      ];
      description = "xl";
      serviceConfig = {
        Type = "simple";
        AmbientCapabilities = [
          "CAP_BPF"
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
          "CAP_SYS_ADMIN"
        ];
        CapabilityBoundingSet = [
          "CAP_BPF"
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
          "CAP_SYS_ADMIN"
        ];
        User = cfg.user;
        Group = cfg.group;

        ExecStart =
          "${pkgs.xl}/bin/xl -c ${cfg.configDir}" + lib.optionalString cfg.enableXdp " --enable-xdp";
        Restart = "on-failure";
        NoNewPrivileges = true;
        StateDirectory = "xl";
        SyslogIdentifier = "xl";
        RuntimeDirectory = "xl";
      };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    users.groups = mkIf (cfg.group == "xl") { xl = { }; };
    users.users = mkIf (cfg.user == "xl") {
      xl = {
        name = "xl";
        group = cfg.group;
        isSystemUser = true;
      };
    };

    environment.systemPackages = [ pkgs.xl ];
  };
}
