{pkgs, ...}: {
  virtualisation.oci-containers.containers."mobilizon" = {
    image = "kaihuri/mobilizon:5.2.2";

    environment = {
      MOBILIZON_INSTANCE_NAME = "Mobilizon";
      MOBILIZON_INSTANCE_HOST = "mobilizon.example.com";
      MOBILIZON_INSTANCE_LISTEN_IP = "0.0.0.0";
      MOBILIZON_INSTANCE_PORT = "4000";
      MOBILIZON_INSTANCE_EMAIL = "noreply@example.com";
      MOBILIZON_REPLY_EMAIL = "contact@example.com";
      MOBILIZON_INSTANCE_REGISTRATIONS_OPEN = "false";
      MOBILIZON_LOGLEVEL = "error";

      MOBILIZON_DATABASE_HOST = "postgis";
      MOBILIZON_DATABASE_PORT = "5432";
      MOBILIZON_DATABASE_USERNAME = "mobilizon";
      MOBILIZON_DATABASE_PASSWORD = "xxxxxx";
      MOBILIZON_DATABASE_DBNAME = "mobilizon";
      MOBILIZON_DATABASE_SSL = "false";

      MOBILIZON_INSTANCE_SECRET_KEY_BASE = "xxxxxx";
      MOBILIZON_INSTANCE_SECRET_KEY = "xxxxxx";

      # ── 邮件 ─────────────
      # MOBILIZON_SMTP_SERVER = "";
      # MOBILIZON_SMTP_PORT = "587";
      # MOBILIZON_SMTP_USERNAME = "noreply@example.com";
      # MOBILIZON_SMTP_PASSWORD = "changeme-smtp-password";
      # MOBILIZON_SMTP_SSL = "false";
      # MOBILIZON_SMTP_TLS = "if_available";
    };

    volumes = [
      # "/etc/mobilizon/config.exs:/etc/mobilizon/config.exs"
      "mobilizon:/var/lib/mobilizon/uploads"
    ];

    ports = [
      "127.0.0.1:43918:4000"
    ];
  };

  systemd.services.create-pg-db-for-mobilizon = {
    wantedBy = ["multi-user.target"];
    after = ["podman-postgis.service"];
    description = "Initialize PostgreSQL users and databases for Mobilizon";
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStart = pkgs.writeShellScript "create-pg-db-for-mobilizon" ''
        ${pkgs.podman}/bin/podman exec -i postgis \
          psql -U postgres \
          -c "CREATE ROLE mobilizon WITH LOGIN PASSWORD 'xxxxxx';" \
          -c "CREATE DATABASE mobilizon WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=mobilizon;"

        ${pkgs.podman}/bin/podman exec -i postgis \
          psql -U postgres -d mobilizon \
          -c "CREATE EXTENSION IF NOT EXISTS postgis;" \
          -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;" \
          -c "CREATE EXTENSION IF NOT EXISTS unaccent;" \
          -c "GRANT ALL PRIVILEGES ON DATABASE mobilizon TO mobilizon;" \
          -c "GRANT ALL ON SCHEMA public TO mobilizon;" \
          -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO mobilizon;" \
          -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO mobilizon;"
      '';
    };
  };
}
