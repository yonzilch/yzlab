{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.spotdl;
  inherit
    (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;
in {
  options.services.spotdl = {
    enable = mkEnableOption "Spotdl";

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/spotdl";
      description = "Directory used to store spotdl files.";
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open the spotdl port in the firewall";
    };
    user = mkOption {
      type = types.str;
      default = "spotdl";
      description = "The user spotdl should run as.";
    };
    group = mkOption {
      type = types.str;
      default = "spotdl";
      description = "The group spotdl should run as.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.spotdl = {
      wantedBy = ["multi-user.target"];
      after = [
        "network.target"
        "nss-lookup.target"
      ];
      description = "spotdl";
      environment = {
        HOME = "${cfg.dataDir}";
      };
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = ''${pkgs.spotdl}/bin/spotdl web'';
        Restart = "on-failure";
        StartLimitBurst = 3;
        RestartSec = "5s";
        StateDirectory = "spotdl";
        SyslogIdentifier = "spotdl";
        RuntimeDirectory = "spotdl";
      };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [8800];

    users.groups = mkIf (cfg.group == "spotdl") {spotdl = {};};
    users.users = mkIf (cfg.user == "spotdl") {
      spotdl = {
        name = "spotdl";
        group = cfg.group;
        isSystemUser = true;
      };
    };

    environment.systemPackages = [pkgs.spotdl];
  };
}
