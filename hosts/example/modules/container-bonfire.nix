{pkgs, ...}: {
  # run command
  # podman exec -it bonfire bin/bonfire eval "Bonfire.Common.Repo.migrate()"
  # to perform db migrate
  virtualisation.oci-containers.containers."bonfire" = {
    image = "bonfirenetworks/bonfire:latest-alpha-social-amd64";
    environment = {
      # ── domain and port ────────────────────────────────────────────
      HOSTNAME = "bonfire.example.com";
      PUBLIC_PORT = "443";
      SERVER_PORT = "4000";

      # ── Secrets ────────────────────────────────────
      SECRET_KEY_BASE = "xxxxxx";
      SIGNING_SALT = "xxxxxx";
      ENCRYPTION_SALT = "xxxxxx";
      ERLANG_COOKIE = "xxxxxx";

      # ── database ────────────────────────────────────────────────
      POSTGRES_HOST = "pgroonga";
      POSTGRES_USER = "bonfire";
      POSTGRES_DB = "bonfire";
      POSTGRES_PASSWORD = "xxxxxx";

      # ── search engine ────────────────────
      SEARCH_MEILI_INSTANCE = "http://meilisearch:7700";
      MEILI_MASTER_KEY = "xxxxxx";

      # ── OIDC SSO ──────────────────────────────────────────────
      OPENID_1_DISCOVERY = "";
      OPENID_1_DISPLAY_NAME = "";
      OPENID_1_CLIENT_ID = "";
      OPENID_1_CLIENT_SECRET = "";
      OPENID_1_SCOPE = "openid email profile";
      OPENID_1_RESPONSE_TYPE = "code";
      # https://bonfire.example.com/oauth/client/openid_1

      # ── email ───────────────
      MAIL_BACKEND = "none";

      # ── functions ──────────────────────────────────────────────
      ENABLE_SSO_PROVIDER = "true";
      LIVEVIEW_ENABLED = "true";
      WITH_API_GRAPHQL = "1";
      DB_MIGRATE_INDEXES_CONCURRENTLY = "false";
      ACME_AGREE = "true";
      REPLACE_OS_VARS = "true";
      PLUG_SERVER = "cowboy";
      OTEL_ENABLED = "0";

      # ── upload ────────────────────────────────────────
      UPLOAD_LIMIT = "100";
      UPLOAD_LIMIT_IMAGES = "100";
      UPLOAD_LIMIT_VIDEOS = "100";

      # ── environment ──────────────────────────────────────────────────
      MIX_ENV = "prod";
      FLAVOUR = "ember";
      LANG = "en_US.UTF-8";
      LANGUAGE = "en_US.UTF-8";

      # ── map ───────────────────────────────────────────
      MAPBOX_API_KEY = "";

      # ── Web Push ──────────
      WEB_PUSH_SUBJECT = "mailto:foobar@example.com";
      # WEB_PUSH_PUBLIC_KEY  = "";
      # WEB_PUSH_PRIVATE_KEY = "";
    };

    volumes = [
      "bonfire_uploads:/opt/app/data/uploads"
    ];

    ports = [
      "127.0.0.1:4000:4000"
    ];
  };

  systemd.services.create-pg-db-for-bonfire = {
    wantedBy = ["multi-user.target"];
    after = ["podman-pgroonga.service"];
    # requires = ["podman-postgres.service"];
    description = "Initialize PostgreSQL users and databases";
    # Without this line, it would Error: configure storage:
    # the 'zfs' command is not available:
    # prerequisites for driver not satisfied (wrong filesystem?)
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i pgroonga \
        psql -U postgres \
        -c "CREATE ROLE bonfire WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE bonfire WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=bonfire;"
      '';
    };
  };
}
