{pkgs, ...}: {
  virtualisation.oci-containers.containers."paperless-ngx" = {
    image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
    pull = "newer";
    dependsOn = [
      "pgroonga"
      "valkey"
      "gotenberg"
      "tika"
    ];
    environment = {
      # ── Database ────────────────────────────────────────────────────
      PAPERLESS_DBHOST = "pgroonga";
      PAPERLESS_DBPORT = "5432";
      PAPERLESS_DBNAME = "paperless-ngx";
      PAPERLESS_DBUSER = "paperless-ngx";
      PAPERLESS_DBPASS = "xxxxxx";

      # ── Redis ───────────────────────────────────────────────────────
      PAPERLESS_REDIS = "redis://valkey:6379";

      # ── Tika & Gotenberg ────────────────────────────────────────────
      PAPERLESS_TIKA_ENABLED = "1";
      PAPERLESS_TIKA_ENDPOINT = "http://tika:9998";
      PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://gotenberg:3000";

      # ── Site / URL settings ─────────────────────────────────────────
      PAPERLESS_URL = "https://paperless.example.com";
      PAPERLESS_SECRET_KEY = "xxxxxx";
      PAPERLESS_TIME_ZONE = "Asia/Singapore";

      # ── OCR languages ───────────────────────────────────────────────
      PAPERLESS_OCR_LANGUAGE = "";
      PAPERLESS_OCR_LANGUAGES = "";

      # ── User / process mapping ──────────────────────────────────────
      USERMAP_UID = "1000";
      USERMAP_GID = "1000";

      # ── Initial admin account (only used on first start) ────────────
      PAPERLESS_ADMIN_USER = "admin"; # ← change or remove after first login
      PAPERLESS_ADMIN_PASSWORD = "xxxxxx";
      PAPERLESS_ADMIN_MAIL = "admin@example.com";
    };

    volumes = [
      "paperless_data:/usr/src/paperless/data"
      "paperless_media:/usr/src/paperless/media"
      "paperless_export:/usr/src/paperless/export"
      "paperless_consume:/usr/src/paperless/consume"
    ];

    ports = [
      "127.0.0.1:35726:8000"
    ];
  };

  systemd.services.create-pg-db-for-paperless-ngx = {
    wantedBy = ["multi-user.target"];
    after = ["podman-pgroonga.service"];
    description = "Initialize PostgreSQL user and database for Paperless-ngx";

    # Without zfs in path → would fail with: "the 'zfs' command is not available"
    path = with pkgs; [zfs];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i pgroonga \
        psql -U postgres \
        -c "CREATE ROLE \"paperless-ngx\" WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE \"paperless-ngx\" WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=\"paperless-ngx\";"
      '';
    };
  };
}
