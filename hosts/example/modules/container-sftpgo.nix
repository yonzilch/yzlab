{ pkgs, ... }:
{
  environment.etc."sftpgo/hooks/pre-login.sh" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      # OIDC 登录时 SFTPGO_LOGIND_PROTOCOL = "OIDC"
      # 用户信息在 SFTPGO_LOGIND_USER 环境变量里（JSON 字符串）
      # 只处理 OIDC 协议，其他协议返回空让 SFTPGo 自己处理

      if [ "$SFTPGO_LOGIND_PROTOCOL" != "OIDC" ]; then
        exit 0
      fi

      username=$(echo "$SFTPGO_LOGIND_USER" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)

      if [ -z "$username" ]; then
        exit 1
      fi

      cat <<EOF
      {
        "username": "$username",
        "status": 1,
        "home_dir": "/srv/sftpgo/data/$username",
        "permissions": {
          "/": ["*"]
        },
        "quota_size": 0,
        "quota_files": 0
      }
      EOF
    '';
  };

  virtualisation.oci-containers.containers."sftpgo" = {
    pull = "newer";
    user = "1000:1000";
    image = "drakkan/sftpgo:v2-slim";
    environment = {
      # see https://docs.sftpgo.com/latest/env-vars/
      # and https://docs.sftpgo.com/latest/config-file/

      # Log to stdout so logs are available via podman logs
      SFTPGO_LOG_FILE_PATH = "";

      # Data provider: PostgreSQL
      SFTPGO_DATA_PROVIDER__DRIVER = "postgresql";
      SFTPGO_DATA_PROVIDER__HOST = "postgres";
      SFTPGO_DATA_PROVIDER__PORT = "5432";
      SFTPGO_DATA_PROVIDER__NAME = "sftpgo";
      SFTPGO_DATA_PROVIDER__USERNAME = "sftpgo";
      SFTPGO_DATA_PROVIDER__PASSWORD = "xxxxxx";
      SFTPGO_DATA_PROVIDER__CREATE_DEFAULT_ADMIN = "true";

      # Default admin credentials (only used on first start)
      SFTPGO_DEFAULT_ADMIN_USERNAME = "foobar";
      SFTPGO_DEFAULT_ADMIN_PASSWORD = "xxxxxx";

      # SFTP service binding
      SFTPGO_SFTPD__BINDINGS__0__PORT = "2022";
      SFTPGO_SFTPD__BINDINGS__0__ADDRESS = "";

      # WebDav service binding
      SFTPGO_WEBDAVD__BINDINGS__0__PORT = "10080";

      # HTTP/WebAdmin binding (internal only)
      SFTPGO_HTTPD__BINDINGS__0__PORT = "8080";
      SFTPGO_HTTPD__BINDINGS__0__ADDRESS = "";
      SFTPGO_HTTPD__BINDINGS__0__ENABLE_WEB_ADMIN = "true";
      SFTPGO_HTTPD__BINDINGS__0__ENABLE_WEB_CLIENT = "true";

      SFTPGO_HTTPD__BINDINGS__0__OIDC__CLIENT_ID = "SkBynclDgUeGD6DA";
      SFTPGO_HTTPD__BINDINGS__0__OIDC__CLIENT_SECRET = "Wsehmw3guPMfWaPgKOpX5ghwdaBGmIbI";
      SFTPGO_HTTPD__BINDINGS__0__OIDC__CONFIG_URL = "https://auth.example.com/oidc";
      SFTPGO_HTTPD__BINDINGS__0__OIDC__REDIRECT_BASE_URL = "https://sftpgo.example.com";
      SFTPGO_HTTPD__BINDINGS__0__OIDC__USERNAME_FIELD = "preferred_username";
      SFTPGO_HTTPD__BINDINGS__0__OIDC__IMPLICIT_ROLES = "false";
      SFTPGO_HTTPD__BINDINGS__0__OIDC__ROLE_FIELD = "sftpgo_role";
      # SFTPGO_HTTPD__BINDINGS__0__OIDC__SCOPES = "openid,profile,email";

      # Prelogin-Hook
      SFTPGO_DATA_PROVIDER__PRE_LOGIN_HOOK = "/etc/sftpgo/hooks/pre-login.sh";

      # Graceful shutdown: wait up to 30 seconds for active transfers to finish
      SFTPGO_GRACE_TIME = "30";

      # Common settings
      SFTPGO_COMMON__DEFENDER__ENABLED = "true";
      SFTPGO_COMMON__DEFENDER__BAN_TIME = "30";
      SFTPGO_COMMON__DEFENDER__THRESHOLD = "10";
    };
    volumes = [
      "sftpgo_data:/srv/sftpgo:rw"
      "sftpgo_home:/var/lib/sftpgo:rw"
      "/etc/sftpgo:/etc/sftpgo:ro"
    ];
    ports = [
      "127.0.0.1:47163:8080"
      "2022:2022"
    ];
    dependsOn = [ "postgres" ];
  };

  systemd.services.create-pg-db-for-sftpgo = {
    wantedBy = [ "multi-user.target" ];
    after = [ "podman-postgres.service" ];
    description = "Initialize PostgreSQL user and database for sftpgo";
    path = with pkgs; [ zfs ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i postgres \
        psql -U postgres \
        -c "CREATE ROLE sftpgo WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE sftpgo WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=sftpgo;"
      '';
    };
  };
}
