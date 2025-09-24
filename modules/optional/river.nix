{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.river;
  inherit
    (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;
in {
  options.services.river = {
    enable = mkEnableOption "river";

    configFile = mkOption {
      type = types.path;
      default = null;
      description = ''
        The path to a file containing the config.
        Please see [river config document](https://onevariable.com/river-user-manual/config/kdl.html).
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to open the default port in the firewall";
    };

    user = mkOption {
      type = types.str;
      default = "river";
      description = "The user river should run as.";
    };

    group = mkOption {
      type = types.str;
      default = "river";
      description = "The group river should run as.";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (_final: prev: {
        river = prev.callPackage ../../pkgs/river/default.nix {};
      })
    ];

    systemd.services.river-server = {
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      description = "river";
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = ''${pkgs.river}/bin/river --config-kdl ${cfg.configFile}'';
        ExecStop = ''on-failure'';
        StateDirectory = "river";
        SyslogIdentifier = "river";
        RuntimeDirectory = "river";
      };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [
      80
      443
    ];

    users.users = mkIf (cfg.user == "river") {
      river = {
        name = "river";
        group = cfg.group;
        isSystemUser = true;
      };
    };
    users.groups = mkIf (cfg.group == "river") {river = {};};

    environment.systemPackages = [pkgs.river];
  };
}
