{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.hermes-agent-dashboard;

  # Derived: hermes always reads $HOME/.hermes
  hermesDir = "${cfg.dataDir}/.hermes";
in {
  ##############################################################################
  # Option declarations
  ##############################################################################
  options.services.hermes-agent-dashboard = {
    enable = lib.mkEnableOption "Hermes Agent web dashboard";

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
      defaultText = lib.literalExpression "inputs.hermes-agent.packages.<system>.default";
      description = "The hermes package to use.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = ''
        Address the dashboard binds to.
        Leave at the default (127.0.0.1) unless you set <option>insecure</option>
        to true and know what you are doing.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 9119;
      description = "TCP port the dashboard listens on.";
    };

    insecure = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Pass --insecure to allow binding to non-localhost addresses.
        WARNING: this exposes API keys on the network.
      '';
    };

    tui = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Expose the in-browser Chat tab (embedded hermes --tui via PTY/WebSocket).
        Equivalent to setting HERMES_DASHBOARD_TUI=1.
      '';
    };

    skipBuild = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Skip the web-UI npm build step and serve the pre-built dist directory.
        Useful in non-interactive / CI contexts where npm is unavailable.
        Pre-build with: cd web && npm run build
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "hermes";
      description = "Unix user that runs the service.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "hermes";
      description = "Unix group that runs the service.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/hermes";
      description = ''
        Home directory for the hermes user.  Hermes stores all state under
        <filename>$dataDir/.hermes/</filename> (auth.json, config.yaml, .env,
        kanban.db, state.db, sessions/, skills/, …).
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/hermes-extra.env";
      description = ''
        Optional path to a file with additional KEY=value pairs loaded by
        systemd before the process starts (e.g. secrets not already present in
        <filename>~/.hermes/.env</filename>).  Must not be world-readable.

        Note: <filename>~/.hermes/.env</filename> is read directly by hermes
        itself at runtime and does NOT need to be listed here.
      '';
    };

    extraEnvironment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {
        HERMES_LOG_LEVEL = "debug";
      };
      description = "Additional environment variables injected into the service.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Open the dashboard port in the NixOS firewall.
        Only meaningful when <option>host</option> is not 127.0.0.1.
      '';
    };
  };

  ##############################################################################
  # Configuration
  ##############################################################################
  config = lib.mkIf cfg.enable {
    # ── Assertions ─────────────────────────────────────────────────────────────
    assertions = [
      {
        assertion = cfg.insecure || cfg.host == "127.0.0.1";
        message = ''
          services.hermes-agent-dashboard: binding to '${cfg.host}' requires
          `insecure = true` (exposes API keys on the network).
        '';
      }
      {
        assertion = !cfg.openFirewall || cfg.insecure;
        message = ''
          services.hermes-agent-dashboard: `openFirewall` only makes sense
          together with `insecure = true` (non-localhost binding).
        '';
      }
    ];

    # ── User / group ───────────────────────────────────────────────────────────
    # Do not declare here as services.hermes-agent already done the job
    #
    # users.users.${cfg.user} = lib.mkIf (cfg.user == "hermes") {
    #   isSystemUser = true;
    #   group = cfg.group;
    #   # HOME must equal dataDir so hermes finds ~/.hermes correctly.
    #   home = cfg.dataDir;
    #   createHome = lib.mkDefault false; # systemd StateDirectory handles creation
    #   description = "Hermes Agent service user";
    # };

    # users.groups.${cfg.group} = lib.mkIf (cfg.group == "hermes") { };

    # ── Firewall ───────────────────────────────────────────────────────────────
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    # ── systemd service ────────────────────────────────────────────────────────
    systemd.services.hermes-agent-dashboard = {
      description = "Hermes Agent Web Dashboard";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      environment = lib.filterAttrs (_: v: v != "") (
        {
          # hermes resolves ~/.hermes from $HOME
          HOME = cfg.dataDir;

          # keep --tui flag and env-var in sync
          HERMES_DASHBOARD_TUI =
            if cfg.tui
            then "1"
            else "";

          # force Python not buffer
          PYTHONUNBUFFERED = "1";

          # suppress interactive prompts / browser launch signals
          TERM = "dumb";
          NO_COLOR = "1";
        }
        // cfg.extraEnvironment
      );

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;

        # ── Directory management ───────────────────────────────────────────────
        # systemd creates /var/lib/hermes (owner: hermes:hermes, mode 0750).
        StateDirectory = baseNameOf cfg.dataDir;
        StateDirectoryMode = "0750";

        # Runtime dir for gateway.pid / gateway.lock (/run/hermes-agent-dashboard/).
        # Cleaned up automatically on stop.
        RuntimeDirectory = "hermes-agent-dashboard";
        RuntimeDirectoryMode = "0750";

        # ── Pre-start: ensure ~/.hermes exists with setgid ─────────────────────
        # hermes creates .hermes/ on first run, but the setgid bit (drwxrws---)
        # must be set so that new files inside inherit the group automatically.
        ExecStartPre = let
          setupScript = pkgs.writeShellScript "hermes-dashboard-prestart" ''
            set -euo pipefail
            HERMES_DIR="${hermesDir}"

            # Create .hermes and key subdirs if they don't exist yet
            for d in \
              "$HERMES_DIR" \
              "$HERMES_DIR/cache" \
              "$HERMES_DIR/cron" \
              "$HERMES_DIR/logs" \
              "$HERMES_DIR/memories" \
              "$HERMES_DIR/platforms" \
              "$HERMES_DIR/plugins" \
              "$HERMES_DIR/sandboxes" \
              "$HERMES_DIR/sessions" \
              "$HERMES_DIR/skills"
            do
              if [ ! -d "$d" ]; then
                mkdir -p "$d"
              fi
              # Ensure setgid bit is present (new files inherit group hermes)
              chmod g+s "$d"
            done

            # Ensure auth.json and .env are never world-readable if they exist
            for f in \
              "$HERMES_DIR/auth.json" \
              "$HERMES_DIR/gateway_state.json"
            do
              [ -f "$f" ] && chmod 0600 "$f" || true
            done
            for f in \
              "$HERMES_DIR/.env" \
              "$HERMES_DIR/config.yaml"
            do
              [ -f "$f" ] && chmod 0640 "$f" || true
            done
          '';
        in "+${setupScript}"; # '+' = run as root for chmod on protected files

        ExecStart = lib.concatStringsSep " " (
          [
            "${cfg.package}/bin/hermes"
          ]
          ++ lib.optional cfg.tui "--tui"
          ++ [
            "dashboard"
            "--host"
            cfg.host
            "--port"
            (toString cfg.port)
            "--no-open" # meaningless (and broken) in a daemon
          ]
          ++ lib.optional cfg.insecure "--insecure"
          ++ lib.optional cfg.skipBuild "--skip-build"
        );

        # ── Stop / restart ─────────────────────────────────────────────────────
        KillSignal = "SIGTERM";
        TimeoutStopSec = 15;
        Restart = "on-failure";
        RestartSec = "5s";

        # ── Secrets ────────────────────────────────────────────────────────────
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;

        # ── File-creation mask ─────────────────────────────────────────────────
        # Matches observed layout:
        #   regular files  → 0640  (rw-r-----)
        #   directories    → 0750  (rwxr-x---) before setgid
        UMask = "0027";

        # ── Hardening ──────────────────────────────────────────────────────────
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;

        # "strict" makes /var/lib read-only globally; ReadWritePaths carves out
        # the hermes state tree.
        ProtectSystem = "strict";
        ReadWritePaths = [
          cfg.dataDir # ~/.hermes, logs, DBs, sessions …
        ];

        # /home and /root are irrelevant for a system service
        ProtectHome = true;

        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;

        # SQLite WAL mode uses mmap(MAP_SHARED|PROT_WRITE) — must stay false.
        MemoryDenyWriteExecute = false;

        SystemCallFilter = "@system-service";
        SystemCallArchitectures = "native";

        CapabilityBoundingSet = ""; # drop all Linux capabilities
        AmbientCapabilities = "";
      };
    };
  };
}
