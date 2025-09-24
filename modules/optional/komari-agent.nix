{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.komari-agent;
  inherit
    (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;
in {
  options.services.komari-agent = {
    enable = mkEnableOption "komari-agent";
    flags = mkOption {
      type = types.str;
      default = "";
      description = "komari-agent run flags";
    };
    user = mkOption {
      type = types.str;
      default = "komari-agent";
      description = "The user komari-agent should run as.";
    };
    group = mkOption {
      type = types.str;
      default = "komari-agent";
      description = "The group komari-agent should run as.";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (_final: prev: {
        komari-agent = prev.callPackage ../../pkgs/komari-agent/default.nix {};
      })
    ];

    systemd.services.komari-agent = {
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      description = "komari-agent";
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.komari-agent}/bin/komari-agent ${cfg.flags}";
        ExecStop = "on-failure";
        StateDirectory = "komari-agent";
        SyslogIdentifier = "komari-agent";
        RuntimeDirectory = "komari-agent";
      };
    };

    users.users = mkIf (cfg.user == "komari-agent") {
      komari-agent = {
        name = "komari-agent";
        group = cfg.group;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "komari-agent") {komari-agent = {};};

    environment.systemPackages = [pkgs.komari-agent];
  };
}
