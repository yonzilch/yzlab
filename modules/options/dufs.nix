{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.dufs;
  inherit
    (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;
in {
  options.services.dufs = {
    enable = mkEnableOption "dufs";

    flags = mkOption {
      type = types.str;
      default = "";
      description = "komari-agent run flags";
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open the dufs port in the firewall";
    };
    port = mkOption {
      type = types.str;
      default = "45781";
      description = "The port which dufs listen.";
    };
    user = mkOption {
      type = types.str;
      default = "dufs";
      description = "The user dufs should run as.";
    };
    group = mkOption {
      type = types.str;
      default = "dufs";
      description = "The group dufs should run as.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.dufs = {
      wantedBy = ["multi-user.target"];
      after = [
        "network.target"
        "nss-lookup.target"
      ];
      description = "dufs";
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.dufs}/bin/dufs -p ${cfg.port} ${cfg.flags}";
        ExecStop = ''on-failure'';
        StateDirectory = "dufs";
        SyslogIdentifier = "dufs";
        RuntimeDirectory = "dufs";
      };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall ["${cfg.port}"];

    users.groups = mkIf (cfg.group == "dufs") {dufs = {};};
    users.users = mkIf (cfg.user == "dufs") {
      dufs = {
        name = "dufs";
        group = cfg.group;
        isSystemUser = true;
      };
    };

    environment.systemPackages = [pkgs.dufs];
  };
}
