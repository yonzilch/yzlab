{pkgs, ...}: {
  virtualisation.oci-containers.containers."homebox" = {
    pull = "newer";
    image = "ghcr.io/sysadminsmedia/homebox:latest";

    environment = {
      # General logging & behavior
      HBOX_LOG_LEVEL = "info";
      HBOX_LOG_FORMAT = "text";
      HBOX_WEB_MAX_FILE_UPLOAD = "10"; # MB
      HBOX_OPTIONS_ALLOW_ANALYTICS = "false";
      HBOX_OPTIONS_ALLOW_REGISTRATION = "false";
      HBOX_OPTIONS_CHECK_GITHUB_RELEASE = "false";
      HBOX_OPTIONS_TRUST_PROXY = "true";

      # OIDC / SSO (recommended: disable local registration when using SSO)
      HBOX_OIDC_ENABLED = "true";
      HBOX_OIDC_ISSUER_URL = "";
      HBOX_OIDC_CLIENT_ID = "xxxxxx";
      HBOX_OIDC_CLIENT_SECRET = "xxxxxx";

      # Database connection
      HBOX_DATABASE_DRIVER = "postgres";
      HBOX_DATABASE_HOST = "postgres";
      HBOX_DATABASE_PORT = "5432";
      HBOX_DATABASE_USERNAME = "homebox";
      HBOX_DATABASE_PASSWORD = "xxxxxx";
      HBOX_DATABASE_DATABASE = "homebox";
      HBOX_DATABASE_SSL_MODE = "disable";
    };

    volumes = [
      "homebox:/data:rw"
    ];

    ports = [
      "127.0.0.1:7745:7745"
    ];
  };

  systemd.services.create-pg-db-for-homebox = {
    wantedBy = ["multi-user.target"];
    after = ["podman-pgroonga.service"];
    description = "Initialize PostgreSQL user and database for homebox";
    # Required when using ZFS-backed storage
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i postgres \
        psql -U postgres \
        -c "CREATE ROLE homebox WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE homebox WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=homebox;"
      '';
    };
  };
}
