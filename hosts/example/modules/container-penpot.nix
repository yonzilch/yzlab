{pkgs, ...}: let
  penpotFlags = "disable-email-verification disable-secure-session-cookies disable-registration disable-login-with-password enable-login-with-oidc enable-oidc-registration enable-prepl-server";
  penpotPublicUri = "https://penpot.example.com";
  penpotSecretKey = "xxxxxx"; # python3 -c "import secrets; print(secrets.token_urlsafe(64))"
  assetsVolume = "penpot_assets:/opt/data/assets";
in {
  # ── Mailcatch（临时 SMTP，可选）──────────────────────────────────────────────
  # 访问 http://localhost:1080 Web UI 查看捕获的邮件
  # virtualisation.oci-containers.containers."penpot-mailcatch" = {
  #   image = "sj26/mailcatcher:latest";
  #   pull = "newer";
  #   ports = [
  #     "127.0.0.1:1080:1080/tcp"
  #   ];
  # };

  # ── Frontend ────────────────────────────────────────────────────────────────
  virtualisation.oci-containers.containers."penpot-frontend" = {
    image = "penpotapp/frontend:latest";
    pull = "newer";
    ports = [
      "127.0.0.1:59001:8080/tcp"
    ];
    volumes = [assetsVolume];
    environment = {
      "PENPOT_FLAGS" = penpotFlags;
      "PENPOT_HTTP_SERVER_MAX_BODY_SIZE" = "367001600";
      "PENPOT_HTTP_SERVER_MAX_MULTIPART_BODY_SIZE" = "367001600";
    };
    dependsOn = [
      "penpot-backend"
    ];
  };

  # ── Backend ─────────────────────────────────────────────────────────────────
  virtualisation.oci-containers.containers."penpot-backend" = {
    image = "penpotapp/backend:latest";
    pull = "newer";
    volumes = [assetsVolume];
    environment = {
      "PENPOT_FLAGS" = penpotFlags;
      "PENPOT_PUBLIC_URI" = penpotPublicUri;
      "PENPOT_HTTP_SERVER_MAX_BODY_SIZE" = "367001600";
      "PENPOT_HTTP_SERVER_MAX_MULTIPART_BODY_SIZE" = "367001600";
      "PENPOT_SECRET_KEY" = penpotSecretKey;

      # PostgreSQL
      "PENPOT_DATABASE_URI" = "postgresql://postgres/penpot";
      "PENPOT_DATABASE_USERNAME" = "penpot";
      "PENPOT_DATABASE_PASSWORD" = "yhNeiLKiPAe0SIrVV2No";

      # Valkey / Redis
      "PENPOT_REDIS_URI" = "redis://valkey/0";

      # OIDC
      # 回调 URL 为 https://<PENPOT_PUBLIC_URI>/api/auth/oidc/callback
      "PENPOT_OIDC_CLIENT_ID" = "SkBynclDgUeGD6DA";
      "PENPOT_OIDC_CLIENT_SECRET" = "Wsehmw3guPMfWaPgKOpX5ghwdaBGmIbI";
      "PENPOT_OIDC_BASE_URI" = "https://auth.example.com/oidc";
      # Penpot 会自动从 base-uri + /.well-known/openid-configuration 拉取 discovery
      # 若 IdP 不支持 discovery，可手动指定：
      "PENPOT_OIDC_AUTH_URI" = "https://auth.example.com/oidc/auth";
      "PENPOT_OIDC_TOKEN_URI" = "https://auth.example.com/oidc/token";
      "PENPOT_OIDC_USER_URI" = "https://auth.example.com/oidc/me";
      "PENPOT_OIDC_SCOPES" = "openid email profile";
      "PENPOT_OIDC_EMAIL_ATTR" = "email";
      "PENPOT_OIDC_NAME_ATTR" = "name";
      "PENPOT_OIDC_USER_INFO_SOURCE" = "token";

      # 本地文件系统存储
      # "PENPOT_OBJECTS_STORAGE_BACKEND" = "fs";
      # "PENPOT_OBJECTS_STORAGE_FS_DIRECTORY" = "/opt/data/assets";

      # S3 / MinIO 存储
      "AWS_ACCESS_KEY_ID" = "7qX3wjFKNul4L6vCSmoU";
      "AWS_SECRET_ACCESS_KEY" = "0sdCxnn44TrWY8Bki5rkc4aAmMCjN4fk";
      "PENPOT_OBJECTS_STORAGE_BACKEND" = "s3";
      "PENPOT_OBJECTS_STORAGE_S3_ENDPOINT" = "https://s3.example.com";
      "PENPOT_OBJECTS_STORAGE_S3_BUCKET" = "penpot";

      # Telemetry
      "PENPOT_TELEMETRY_ENABLED" = "false";
      "PENPOT_TELEMETRY_REFERER" = "compose";

      # SMTP → 内部 mailcatch
      # "PENPOT_SMTP_DEFAULT_FROM" = "no-reply@example.com";
      # "PENPOT_SMTP_DEFAULT_REPLY_TO" = "no-reply@example.com";
      # "PENPOT_SMTP_HOST" = "penpot-mailcatch";
      # "PENPOT_SMTP_PORT" = "1025";
      # "PENPOT_SMTP_TLS" = "false";
      # "PENPOT_SMTP_SSL" = "false";

      # SMTP
      # "PENPOT_SMTP_DEFAULT_FROM" = "do-not-reply@example.com";
      # "PENPOT_SMTP_DEFAULT_REPLY_TO" = "do-not-reply@example.com";
      # "PENPOT_SMTP_HOST" = "mail.example.com";
      # "PENPOT_SMTP_PORT" = "587";
      # "PENPOT_SMTP_USERNAME" = "do-not-reply@example.com";
      # "PENPOT_SMTP_PASSWORD" = "xxxxxx";
      # "PENPOT_SMTP_TLS" = "false";
      # "PENPOT_SMTP_SSL" = "false";
    };
    dependsOn = [
      "postgres"
      "valkey"
    ];
  };

  # ── Exporter ─────────────────────────────────────────────────────────────────
  virtualisation.oci-containers.containers."penpot-exporter" = {
    image = "penpotapp/exporter:latest";
    pull = "newer";
    environment = {
      "PENPOT_SECRET_KEY" = penpotSecretKey;
      "PENPOT_PUBLIC_URI" = "http://penpot-frontend:8080";
      "PENPOT_REDIS_URI" = "redis://valkey/0";
    };
    dependsOn = [
      "valkey"
    ];
  };

  # ── MCP ────────────────────────────────────────────────────────────────
  virtualisation.oci-containers.containers."penpot-mcp" = {
    image = "penpotapp/mcp:latest";
    pull = "newer";
  };

  systemd.services.create-pg-db-for-penpot = {
    wantedBy = ["multi-user.target"];
    after = ["podman-postgres.service"];
    description = "Initialize PostgreSQL role and database for Penpot";
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = let
        psql = "${pkgs.podman}/bin/podman exec -i postgres psql -U postgres";
      in
        pkgs.writeShellScript "create-pg-db-for-penpot" ''
          if ${psql} -tAc "SELECT 1 FROM pg_database WHERE datname='penpot'" | grep -q 1; then
            echo "Database 'penpot' already exists, skipping initialization."
            exit 0
          fi

          echo "Creating role and database for penpot..."
          ${psql} \
            -c "CREATE ROLE penpot WITH LOGIN PASSWORD 'xxxxxx';" \
            -c "CREATE DATABASE penpot WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=penpot;"
        '';
    };
  };
}
