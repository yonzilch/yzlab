{pkgs, ...}: {
  # Authentik Server (主服务)
  virtualisation.oci-containers.containers."authentik-server" = {
    pull = "newer";
    image = "ghcr.io/goauthentik/server:2025.10";

    cmd = ["server"];

    dependsOn = [
      "postgres"
      "keydb"
    ];

    volumes = [
      "authentik_media:/media:rw"
      "authentik_templates:/templates:rw"
    ];

    ports = [
      "127.0.0.1:9000:9000" # HTTP
      "127.0.0.1:9443:9443" # HTTPS (内部使用)
    ];

    environmentFiles = [
      "/run/secrets/authentik-env"
    ];

    environment = {
      "AUTHENTIK_REDIS__HOST" = "keydb";
      "AUTHENTIK_POSTGRESQL__HOST" = "postgres";
      "AUTHENTIK_POSTGRESQL__NAME" = "authentik";
      "AUTHENTIK_POSTGRESQL__USER" = "authentik";

      # 错误报告 (可选，生产建议禁用)
      "AUTHENTIK_ERROR_REPORTING__ENABLED" = "false";

      # 日志级别
      "AUTHENTIK_LOG_LEVEL" = "info";

      # 监听配置
      "AUTHENTIK_LISTEN__HTTP" = "0.0.0.0:9000";
      "AUTHENTIK_LISTEN__HTTPS" = "0.0.0.0:9443";
    };

    extraOptions = [
      "--health-cmd=ak healthcheck"
      "--health-interval=30s"
      "--health-timeout=10s"
      "--health-retries=3"
      "--health-start-period=90s"
    ];
  };

  # Authentik Worker (后台任务处理)
  virtualisation.oci-containers.containers."authentik-worker" = {
    pull = "newer";
    image = "ghcr.io/goauthentik/server:2025.10";

    cmd = ["worker"];

    dependsOn = [
      "postgres"
      "keydb"
    ];

    volumes = [
      "authentik-media:/media:rw"
      "authentik-templates:/templates:rw"
      "authentik-certs:/certs:rw"
      "/var/run/podman/podman.sock:/var/run/docker.sock:rw" # Docker API 访问
    ];

    environmentFiles = [
      "/run/secrets/authentik-env"
    ];

    environment = {
      "AUTHENTIK_REDIS__HOST" = "keydb";
      "AUTHENTIK_POSTGRESQL__HOST" = "postgres";
      "AUTHENTIK_POSTGRESQL__NAME" = "authentik";
      "AUTHENTIK_POSTGRESQL__USER" = "authentik";
      "AUTHENTIK_LOG_LEVEL" = "info";
    };
  };

  # 创建环境变量文件模板
  system.activationScripts.authentik-secrets = ''
        mkdir -p /run/secrets
        if [ ! -f /run/secrets/authentik-env ]; then
          # 生成随机密钥
          SECRET_KEY=$(${pkgs.openssl}/bin/openssl rand -base64 60 | tr -d '\n')

          cat > /run/secrets/authentik-env << EOF
    # Authentik 核心配置
    AUTHENTIK_SECRET_KEY=$SECRET_KEY
    AUTHENTIK_POSTGRESQL__PASSWORD=xxxxxx

    # 邮件配置 (可选但推荐)
    # AUTHENTIK_EMAIL__HOST=
    # AUTHENTIK_EMAIL__PORT=587
    # AUTHENTIK_EMAIL__USERNAME=
    # AUTHENTIK_EMAIL__PASSWORD=
    # AUTHENTIK_EMAIL__USE_TLS=true
    # AUTHENTIK_EMAIL__FROM=

    # Redis 密码 (如果 KeyDB 启用了认证)
    # AUTHENTIK_REDIS__PASSWORD=your_redis_password

    # 公开访问 URL
    AUTHENTIK_HOST=https://auth.example.com
    AUTHENTIK_INSECURE=false

    # 管理员引导配置 (首次运行后可删除)
    AUTHENTIK_BOOTSTRAP_PASSWORD=xxxxxx
    AUTHENTIK_BOOTSTRAP_EMAIL=foobar@example.com
    AUTHENTIK_BOOTSTRAP_TOKEN=xxxxxx
    EOF
          chmod 600 /run/secrets/authentik-env
          echo "Authentik 密钥已生成，请编辑 /run/secrets/authentik-env"
        fi
  '';

  systemd.services.create-pg-db-for-authentik = {
    wantedBy = ["multi-user.target"];
    after = ["podman-postgres.service"];
    # requires = ["podman-postgres.service"];
    description = "Initialize PostgreSQL users and databases";
    # Without this line, it would Error: configure storage:
    # the 'zfs' command is not available:
    # prerequisites for driver not satisfied (wrong filesystem?)
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      SuccessExitStatus = "0 1";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i postgres \
        psql -U postgres \
        -c "CREATE ROLE authentik WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE authentik WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=authentik;"
      '';
    };
  };
}
