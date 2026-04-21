{pkgs, ...}: let
  sharedEnv = {
    # see https://github.com/multica-ai/multica/blob/main/.env.example
    # Database
    POSTGRES_DB = "multica";
    POSTGRES_USER = "multica";
    POSTGRES_PASSWORD = "xxxxxx";
    POSTGRES_PORT = "5432";
    DATABASE_URL = "postgres://multica:xxxxxx@pgvector:5432/multica?sslmode=disable";

    # Server
    APP_ENV = "production";
    PORT = "8080";
    JWT_SECRET = "xxxxxx";
    MULTICA_SERVER_URL = "wss://multica.example.com/ws";
    MULTICA_APP_URL = "https://multica.example.com";
    MULTICA_DAEMON_POLL_INTERVAL = "3s";
    MULTICA_DAEMON_HEARTBEAT_INTERVAL = "15s";
    MULTICA_CODEX_PATH = "codex";
    MULTICA_CODEX_TIMEOUT = "20m";

    # CORS / WebSocket origins
    ALLOWED_ORIGINS = "https://multica.example.com";

    # Frontend
    FRONTEND_PORT = "3000";
    FRONTEND_ORIGIN = "https://multica.example.com";
    NEXT_PUBLIC_API_URL = "https://multica.example.com";
    NEXT_PUBLIC_WS_URL = "wss://multica.example.com";

    # Signup control
    ALLOW_SIGNUP = "true";
    NEXT_PUBLIC_ALLOW_SIGNUP = "true";

    # Local file storage fallback (no S3 configured)
    LOCAL_UPLOAD_DIR = "/app/data/uploads";
    LOCAL_UPLOAD_BASE_URL = "https://multica.example.com";
  };
in {
  virtualisation.oci-containers.containers."multica-backend" = {
    pull = "newer";
    image = "ghcr.io/yonzilch/multica-fork-backend:main";

    environment = sharedEnv;

    volumes = [
      "multica_uploads:/app/data/uploads:rw"
    ];

    ports = [
      "127.0.0.1:4380:8080"
    ];

    dependsOn = ["pgvector"];
  };

  virtualisation.oci-containers.containers."multica-frontend" = {
    pull = "newer";
    image = "ghcr.io/yonzilch/multica-fork-frontend:main";

    environment = sharedEnv;

    volumes = [
      "multica_uploads:/app/data/uploads:rw"
    ];

    ports = [
      "127.0.0.1:43000:8080"
    ];

    dependsOn = ["pgvector"];
  };

  systemd.services.create-pg-db-for-multica = {
    wantedBy = ["multi-user.target"];
    after = ["podman-pgvector.service"];
    description = "Initialize PostgreSQL users and databases for multica";
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i pgvector \
        psql -U postgres \
        -c "CREATE ROLE multica WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE multica WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=multica;"
      '';
    };
  };
}
