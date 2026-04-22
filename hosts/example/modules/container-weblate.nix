{pkgs, ...}: {
  virtualisation.oci-containers.containers."weblate" = {
    image = "weblate/weblate:latest";
    pull = "newer";
    environment = {
      # ── 数据库 ──────────────────────────────
      "POSTGRES_USER" = "weblate";
      "POSTGRES_PASSWORD" = "xxxxxx";
      "POSTGRES_DATABASE" = "weblate";
      "POSTGRES_HOST" = "postgres";
      "POSTGRES_PORT" = "5432";

      # ── Redis / Valkey 缓存 ──────────────────────────────────────────
      "REDIS_HOST" = "valkey";
      "REDIS_PORT" = "6379";

      # ── 站点 & 域名 ──────────────────────────────────────────────────
      "IP_BEHIND_REVERSE_PROXY" = "True";
      "STATUS_URL" = "https://status.example.com";
      "WEBLATE_SITE_DOMAIN" = "weblate.example.com";
      "WEBLATE_SITE_TITLE" = "weblate | foobar";
      "WEBLATE_ALLOWED_HOSTS" = "weblate.example.com";
      "WEBLATE_ENABLE_HTTPS" = "True";
      "WEBLATE_SECURE_PROXY_SSL_HEADER" = "HTTP_X_FORWARDED_PROTO,https";

      # ── 管理员账号 ───────────────────────────────────────────────────
      "ADMINS_CONTACT" = "contact@example.com";
      "WEBLATE_ADMIN_NAME" = "foobar";
      "WEBLATE_ADMIN_EMAIL" = "foobar@example.com";
      "WEBLATE_ADMIN_PASSWORD" = "xxxxxx";
      # Notice: You can use these commands to configure superuser account:
      # podman exec -it weblate sh
      # weblate createsuperuser

      # ── 邮件 ─────────────────────────────────────────────────────────
      "WEBLATE_EMAIL_HOST" = "mail.example.com";
      "WEBLATE_EMAIL_HOST_USER" = "do-not-reply@example.com";
      "WEBLATE_EMAIL_HOST_PASSWORD" = "xxxxxx";
      "WEBLATE_EMAIL_PORT" = "587";
      "WEBLATE_SERVER_EMAIL" = "do-not-reply@example.com";
      "WEBLATE_DEFAULT_FROM_EMAIL" = "do-not-reply@example.com";

      # ── 禁用本地密码登录，强制走 OIDC SSO ───────────────────────────
      # 设置后登录页面将只显示 OIDC 入口，不显示用户名/密码表单
      "WEBLATE_NO_EMAIL_AUTH" = "1";
      "REGISTRATION_OPEN" = "True";
      "REGISTRATION_ALLOW_BACKENDS" = ''["Oidc"]'';

      # ── OIDC SSO (social-auth-app-django OIDC 后端) ──────────────────
      # 回调 URL 格式 https://weblate.example.com/accounts/complete/oidc/
      # OIDC discovery endpoint，Weblate 会自动读取 /.well-known/openid-configuration
      "WEBLATE_SOCIAL_AUTH_OIDC_OIDC_ENDPOINT" = "https://auth.example.com/oidc";
      "WEBLATE_SOCIAL_AUTH_OIDC_KEY" = "SkBynclDgUeGD6DA";
      "WEBLATE_SOCIAL_AUTH_OIDC_SECRET" = "Wsehmw3guPMfWaPgKOpX5ghwdaBGmIbI";
      # 要求的 scope（openid + email + profile 以获取用户名、邮箱）
      "WEBLATE_SOCIAL_AUTH_OIDC_SCOPE" = "openid email profile";
      # 从 userinfo 中读取用户名的字段（默认 preferred_username）
      "WEBLATE_SOCIAL_AUTH_OIDC_USERNAME_KEY" = "preferred_username";

      # ── 时区 & 语言 ──────────────────────────────────────────────────
      "WEBLATE_TIME_ZONE" = "Asia/Singapore";

      # ── 提交身份（Git 提交时使用）────────────────────────────────────
      "WEBLATE_DEFAULT_COMMITER_EMAIL" = "weblate@example.com";
      "WEBLATE_DEFAULT_COMMITER_NAME" = "weblate";

      # ── 其他配置 ────────────────────────────────────
      "ENABLE_AVATARS" = "False";
      "ENABLE_SHARING" = "True";
      "WEBSITE_REQUIRED" = "False";
      "WEBSITE_ALERTS_ENABLED" = "False";
      "SENTRY_MONITOR_BEAT_TASKS" = "False";
      "SENTRY_SEND_PII" = "False";
    };
    volumes = [
      "weblate_data:/app/data"
      # see https://docs.weblate.org/zh-cn/latest/admin/install/docker.html#customizing-code
      # "weblate_customization:/app/data/python/weblate_customization"
    ];
    ports = [
      "127.0.0.1:40392:8080/tcp"
    ];
    dependsOn = [
      "postgres"
      "valkey"
    ];
  };

  systemd.services.create-pg-db-for-weblate = {
    wantedBy = ["multi-user.target"];
    after = ["podman-postgres.service"];
    description = "Initialize PostgreSQL users and databases for Weblate";
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = let
        psql = "${pkgs.podman}/bin/podman exec -i postgres psql -U postgres";
      in
        pkgs.writeShellScript "create-pg-db-for-weblate" ''
          if ${psql} -tAc "SELECT 1 FROM pg_database WHERE datname='weblate'" | grep -q 1; then
            echo "Database 'weblate' already exists, skipping initialization."
            exit 0
          fi
          echo "Creating role and database for weblate..."
          ${psql} \
            -c "CREATE ROLE weblate WITH LOGIN PASSWORD 'xxxxxx';" \
            -c "CREATE DATABASE weblate WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=weblate;"
        '';
    };
  };
}
