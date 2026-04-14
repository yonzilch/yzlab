{pkgs, ...}: {
  virtualisation.oci-containers.containers."linkwarden" = {
    image = "ghcr.io/linkwarden/linkwarden:latest";
    pull = "newer";
    environment = {
      "NEXTAUTH_SECRET" = "xxxxxx";
      "DATABASE_URL" = "postgresql://linkwarden:xxxxxx@postgres:5432/linkwarden";
      # "MEILI_HOST" = "http://meilisearch:7700";
      # "MEILI_MASTER_KEY" = "xxxxxx";

      "PAGINATION_TAKE_COUNT" = "50";
      "STORAGE_FOLDER" = "/data";
      "AUTOSCROLL_TIMEOUT" = "30";
      "RE_ARCHIVE_LIMIT" = "5";

      # OIDC SSO
      "NEXT_PUBLIC_DISABLE_REGISTRATION" = "true";
      "DISABLE_NEW_SSO_USERS" = "false";
      "NEXTAUTH_URL" = "https://link.example.com/api/v1/auth";
      "NEXT_PUBLIC_AUTHENTIK_ENABLED" = "true";
      "AUTHENTIK_CUSTOM_NAME" = "OIDC";
      "AUTHENTIK_ISSUER" = "https://auth.example.com/oidc";
      "AUTHENTIK_CLIENT_ID" = "xxxxxx";
      "AUTHENTIK_CLIENT_SECRET" = "xxxxxx";

      # S3
      "SPACES_KEY" = "xxxxxx";
      "SPACES_SECRET" = "xxxxxx";
      "SPACES_ENDPOINT" = "https://s3.example.com";
      "SPACES_BUCKET_NAME" = "link";
      "SPACES_REGION" = "xxxxxx";
      "SPACES_FORCE_PATH_STYLE" = "true";
    };
    ports = [
      "127.0.0.1:47391:3000/tcp"
    ];
    volumes = [
      "linkwarden:/data/data"
    ];
    dependsOn = [
      "postgres"
    ];
  };

  systemd.services.create-pg-db-for-linkwarden = {
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
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i postgres \
        psql -U postgres \
        -c "CREATE ROLE linkwarden WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE linkwarden WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=linkwarden;"
      '';
    };
  };
}
