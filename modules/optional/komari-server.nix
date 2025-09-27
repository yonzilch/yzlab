{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.komari-server;
  inherit
    (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;
in {
  options.services.komari-server = {
    enable = mkEnableOption "komari-server";

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open the default port in the firewall";
    };
    port = mkOption {
      type = types.str;
      default = "25774";
      description = "The port for komari-server to listen";
    };
    user = mkOption {
      type = types.str;
      default = "komari-server";
      description = "The user komari-server should run as.";
    };
    group = mkOption {
      type = types.str;
      default = "komari-server";
      description = "The group komari-server should run as.";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (_final: prev: {
        komari-server = prev.callPackage ../../pkgs/komari-server/default.nix {};
      })
    ];

    systemd.services.komari-server = {
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      description = "komari-server";
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.komari-server}/bin/komari server -l 0.0.0.0:${cfg.port}";
        ExecStop = "on-failure";
        StateDirectory = "komari-server";
        SyslogIdentifier = "komari-server";
        RuntimeDirectory = "komari-server";
        WorkingDirectory = "/var/lib/komari-server";
      };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall ["${cfg.port}"];

    users.users = mkIf (cfg.user == "komari-server") {
      komari-server = {
        name = "komari-server";
        group = cfg.group;
        isSystemUser = true;
      };
    };
    users.groups = mkIf (cfg.group == "komari-server") {komari-server = {};};

    environment.systemPackages = [pkgs.komari-server];
  };
}
