{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.openlist;
  inherit
    (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;
in {
  options.services.openlist = {
    enable = mkEnableOption "Openlist";

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/openlist";
      description = "Directory used to store openlist files.";
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open the openlist port in the firewall";
    };
    user = mkOption {
      type = types.str;
      default = "openlist";
      description = "The user openlist should run as.";
    };
    group = mkOption {
      type = types.str;
      default = "openlist";
      description = "The group openlist should run as.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.openlist = {
      wantedBy = ["multi-user.target"];
      after = [
        "network.target"
        "nss-lookup.target"
      ];
      description = "openlist";
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = ''${pkgs.openlist}/bin/OpenList server --data ${cfg.dataDir}'';
        ExecStop = ''on-failure'';
        StateDirectory = "openlist";
        SyslogIdentifier = "openlist";
        RuntimeDirectory = "openlist";
      };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [5244];

    users.groups = mkIf (cfg.group == "openlist") {openlist = {};};
    users.users = mkIf (cfg.user == "openlist") {
      openlist = {
        name = "openlist";
        group = cfg.group;
        isSystemUser = true;
      };
    };

    environment.systemPackages = [pkgs.openlist];
  };
}
