{pkgs, ...}: {
  virtualisation.oci-containers.containers."gotosocial" = {
    image = "docker.io/superseriousbusiness/gotosocial:latest";
    user = "1000:1000";

    environment = {
      # ── Required / instance identity ──────────────────────────────
      GTS_HOST = "social.example.com";
      GTS_PROTOCOL = "https";

      # ── Database (PostgreSQL) ─────────────────────────────────────
      GTS_DB_TYPE = "postgres";
      GTS_DB_ADDRESS = "postgres";
      GTS_DB_PORT = "5432";
      GTS_DB_USER = "gotosocial";
      GTS_DB_PASSWORD = "xxxxxx";
      GTS_DB_DATABASE = "gotosocial";
      GTS_DB_TLS_MODE = "disable";

      # ── Network / proxy settings ──────────────────────────────────
      GTS_BIND_ADDRESS = "0.0.0.0";
      GTS_PORT = "8080";
      GTS_TRUSTED_PROXIES = "127.0.0.1/32,::1,10.88.0.1/32";

      # ── TLS (handled by reverse proxy) ─────────────────────────────
      GTS_LETSENCRYPT_ENABLED = "false";

      # ── Storage & cache ───────────────────────────────────────────
      GTS_STORAGE_LOCAL_BASE_PATH = "/gotosocial/storage";
      GTS_WAZERO_COMPILATION_CACHE = "/gotosocial/.cache";

      # ── OIDC / SSO ────────────────────────────────────────────────
      GTS_OIDC_ENABLED = "true";
      GTS_OIDC_IDP_NAME = "Example SSO";
      GTS_OIDC_ISSUER = "https://auth.example.com/oidc";
      GTS_OIDC_CLIENT_ID = "xxxxxx";
      GTS_OIDC_CLIENT_SECRET = "xxxxxx";
      GTS_OIDC_SCOPES = "openid,email,profile";
      GTS_OIDC_LINK_EXISTING = "true";

      # ── Instance visibility & registration ────────────────────────
      GTS_INSTANCE_EXPOSE_PUBLIC_TIMELINE = "false";
      GTS_INSTANCE_EXPOSE_PEERS = "false";
      GTS_INSTANCE_EXPOSE_SUSPENDED = "false";
      GTS_ACCOUNTS_REGISTRATION_OPEN = "false";
      GTS_ACCOUNTS_APPROVAL_REQUIRED = "true";

      # ── Logging ───────────────────────────────────────────────────
      GTS_LOG_LEVEL = "info";
      GTS_LOG_FORMAT = "logfmt";
      GTS_LOG_CLIENT_IP = "true";
      TZ = "Asia/Singapore";
    };

    volumes = [
      "gotosocial_storage:/gotosocial/storage"
      "gotosocial_cache:/gotosocial/.cache"
    ];

    ports = [
      "127.0.0.1:8085:8080"
    ];
  };

  systemd.services.create-pg-db-for-gotosocial = {
    wantedBy = ["multi-user.target"];
    after = ["podman-postgres.service"];
    description = "Initialize PostgreSQL user and database for gotosocial";
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i postgres \
        psql -U postgres \
        -c "CREATE ROLE gotosocial WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE gotosocial WITH LOCALE='C.UTF-8' TEMPLATE=template0 OWNER=gotosocial;"

        ${pkgs.podman}/bin/podman exec -i postgres \
        psql -U postgres -d gotosocial \
        -c "GRANT ALL PRIVILEGES ON DATABASE gotosocial TO gotosocial;" \
        -c "GRANT CREATE ON SCHEMA public TO gotosocial;"
      '';
    };
  };
}
