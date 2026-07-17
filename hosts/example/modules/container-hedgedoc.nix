{ pkgs, ... }:
{
  virtualisation.oci-containers.containers."hedgedoc" = {
    image = "quay.io/hedgedoc/hedgedoc:latest";
    pull = "newer";
    dependsOn = [ "postgres" ];
    environment = {
      # Database
      "CMD_DB_URL" = "postgres://hedgedoc:xxxxxx@postgres/hedgedoc?sslmode=disable";

      "CMD_SESSION_SECRET" = ""; # use command `pwgen -s 64 1` to generate

      # Domain & URL
      "CMD_DOMAIN" = "doc.example.com";
      "CMD_PROTOCOL_USESSL" = "true";
      "CMD_URL_ADDPORT" = "false";
      "CMD_ALLOW_ORIGIN" = "['doc.example.com']";

      # Email
      "CMD_EMAIL" = "false";
      "CMD_ALLOW_EMAIL_REGISTER" = "false";

      # OIDC SSO
      "CMD_OAUTH2_PROVIDERNAME" = "auth";
      "CMD_OAUTH2_CLIENT_ID" = "xxxxxx";
      "CMD_OAUTH2_CLIENT_SECRET" = "xxxxxx";
      "CMD_OAUTH2_SCOPE" = "openid email profile";
      "CMD_OAUTH2_AUTHORIZATION_URL" = "https://auth.example.com/oidc/auth";
      "CMD_OAUTH2_TOKEN_URL" = "https://auth.example.com/oidc/token";
      "CMD_OAUTH2_USER_PROFILE_URL" = "https://auth.example.com/oidc/me";
      "CMD_OAUTH2_USER_PROFILE_USERNAME_ATTR" = "preferred_username";
      "CMD_OAUTH2_USER_PROFILE_DISPLAY_NAME_ATTR" = "name";
      "CMD_OAUTH2_USER_PROFILE_EMAIL_ATTR" = "email";
      "CMD_OAUTH2_USER_PROFILE_ID_ATTR" = "sub";

      # image
      "CMD_IMAGE_UPLOAD_TYPE" = "minio";
      "CMD_S3_BUCKET" = "doc";
      "CMD_S3_FOLDER" = "uploads";
      "CMD_MINIO_ACCESS_KEY" = "xxxxxx";
      "CMD_MINIO_SECRET_KEY" = "xxxxxx";
      "CMD_MINIO_ENDPOINT" = "s3.examplde.com";
      "CMD_MINIO_PORT" = "443";
      "CMD_MINIO_SECURE" = "true";
    };
    # volumes = [
    #   "hedgedoc_uploads:/hedgedoc/public/uploads"
    # ];
    ports = [
      "127.0.0.1:40815:3000/tcp"
    ];
  };

  systemd.services.create-pg-db-for-hedgedoc = {
    wantedBy = [ "multi-user.target" ];
    after = [ "podman-postgres.service" ];
    description = "Initialize PostgreSQL users and databases for HedgeDoc";
    path = with pkgs; [ zfs ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i postgres \
        psql -U postgres \
        -c "CREATE ROLE hedgedoc WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE hedgedoc WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=hedgedoc;"
      '';
    };
  };
}
