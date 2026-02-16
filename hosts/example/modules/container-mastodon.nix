{pkgs, ...}: {
  virtualisation.oci-containers.containers."mastodon" = {
    image = "lscr.io/linuxserver/mastodon:glitch";
    environment = {
      # ── Container user ────────────────────────────────────────
      PUID = "1000";
      PGID = "1000";
      TZ = "Asia/Singapore";
      # ── Domain settings ───────────────────────────────────────
      LOCAL_DOMAIN = "mastodon.example.com"; # ← Account domain @user@mastodon.example.com
      WEB_DOMAIN = "mastodon.example.com"; # ← Actual access domain
      # ── Database ──────────────────────────────────────────────
      DB_HOST = "pgroonga";
      DB_PORT = "5432";
      DB_USER = "mastodon";
      DB_PASS = "xxxxxx";
      DB_NAME = "mastodon";
      # ── Redis (using existing valkey) ─────────────────────────
      REDIS_HOST = "valkey";
      REDIS_PORT = "6379";
      # ── Secrets (generate with the corresponding commands) ────
      SECRET_KEY_BASE = "xxxxxx";
      OTP_SECRET = "xxxxxx";
      VAPID_PRIVATE_KEY = "xxxxxx";
      VAPID_PUBLIC_KEY = "xxxxxx";
      ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY = "xxxxxx";
      ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY = "xxxxxx";
      ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT = "xxxxxx";
      # ── OIDC SSO ──────────────────────────────────────────────
      OMNIAUTH_ONLY = "false"; # true = disable local password login
      OIDC_ENABLED = "true";
      OIDC_DISPLAY_NAME = "";
      OIDC_ISSUER = "https://auth.example.com/oidc";
      OIDC_DISCOVERY = "true";
      OIDC_SCOPE = "openid,email,profile";
      OIDC_UID_FIELD = "sub";
      OIDC_CLIENT_ID = "xxxxxx";
      OIDC_CLIENT_SECRET = "xxxxxx";
      OIDC_REDIRECT_URI = "https://mastodon.example.com/auth/auth/openid_connect/callback";
      OIDC_SECURITY_ASSUME_EMAIL_IS_VERIFIED = "true";
      # ── Email ─────────────────────────────────────────────────
      # SMTP_SERVER = "";
      # SMTP_PORT = "587";
      # SMTP_LOGIN = "noreply@example.com";
      # SMTP_PASSWORD = "xxxxxx";
      # SMTP_FROM_ADDRESS = "notifications@example.com";
      # SMTP_TLS = "false";
      # SMTP_STARTTLS = "auto";
      # ── Search (ZincSearch, ES compatible) ────────────────────
      ES_ENABLED = "true";
      ES_HOST = "http://zincsearch"; # Note: http:// prefix, no TLS
      ES_PORT = "4080"; # Default ZincSearch port
      ES_USER = "admin";
      ES_PASS = "xxxxxx";
      ES_PRESET = "single_node_cluster";
      ES_PREFIX = "mastodon"; # Avoid index name conflicts
      # ── Storage (local) ───────────────────────────────────────
      S3_ENABLED = "false";
      # ── Sidekiq ───────────────────────────────────────────────
      SIDEKIQ_ONLY = "false";
      SIDEKIQ_THREADS = "5";
      DB_POOL = "5";
    };
    volumes = [
      "mastodon:/config"
    ];
    ports = [
      "127.0.0.1:5443:443" # nginx secure tls
      "127.0.0.1:53000:3000" # Rails web
      "127.0.0.1:54000:4000" # Streaming
    ];
  };

  systemd.services.create-pg-db-for-mastodon = {
    wantedBy = ["multi-user.target"];
    after = ["podman-pgroonga.service"];
    description = "Initialize PostgreSQL users and databases for Mastodon";
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i pgroonga \
        psql -U postgres \
        -c "CREATE ROLE mastodon WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE mastodon WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=mastodon;"
      '';
    };
  };
}
