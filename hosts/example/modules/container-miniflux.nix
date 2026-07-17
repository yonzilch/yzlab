{ pkgs, ... }:
{
  virtualisation.oci-containers.containers."miniflux" = {
    image = "miniflux/miniflux:latest";
    pull = "newer";
    environment = {
      "BASE_URL" = "https://rss.example.com";
      "DATABASE_URL" = "postgres://miniflux:xxxxxx@postgres/miniflux?sslmode=disable";
      "OAUTH2_CLIENT_ID" = "xxxxxx";
      "OAUTH2_CLIENT_SECRET" = "xxxxxx";
      "OAUTH2_OIDC_DISCOVERY_ENDPOINT" = "https://auth.example.com/oidc";
      "OAUTH2_PROVIDER" = "oidc";
      "OAUTH2_REDIRECT_URL" = "https://rss.example.com/oauth2/oidc/callback";
      "OAUTH2_USER_CREATION" = "true";
      "RUN_MIGRATIONS" = "1";

      # "CREATE_ADMIN" = "1";
      # "ADMIN_USERNAME" = "foobar";
      # "ADMIN_PASSWORD" = "xxxxxx";
    };
    ports = [
      "127.0.0.1:49136:8080/tcp"
    ];
  };

  systemd.services.create-pg-db-for-miniflux = {
    wantedBy = [ "multi-user.target" ];
    after = [ "podman-postgres.service" ];
    # requires = ["podman-postgres.service"];
    description = "Initialize PostgreSQL users and databases";
    # Without this line, it would Error: configure storage:
    # the 'zfs' command is not available:
    # prerequisites for driver not satisfied (wrong filesystem?)
    path = with pkgs; [ zfs ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i postgres \
        psql -U postgres \
        -c "CREATE ROLE miniflux WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE miniflux WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=miniflux;"
      '';
    };
  };
}
