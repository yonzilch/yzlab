{pkgs, ...}: {
  virtualisation.oci-containers.containers."vikunja" = {
    image = "vikunja/vikunja:latest";
    dependsOn = [
      "postgres"
      "valkey"
    ];
    environment = {
      # see https://vikunja.io/docs/config-options
      # Database
      "VIKUNJA_DATABASE_HOST" = "postgres:5432";
      "VIKUNJA_DATABASE_TYPE" = "postgres";
      "VIKUNJA_DATABASE_USER" = "vikunja";
      "VIKUNJA_DATABASE_PASSWORD" = "xxxxxx";
      "VIKUNJA_DATABASE_DATABASE" = "vikunja";

      # Service
      "VIKUNJA_SERVICE_PUBLICURL" = "https://task.example.com";
      "VIKUNJA_SERVICE_SECRET" = "xxxxxx";
      "VIKUNJA_SERVICE_TIMEZONE" = "Asia/Singapore";
      "VIKUNJA_SERVICE_ENABLEREGISTRATION" = "false";
      "VIKUNJA_SERVICE_IPEXTRACTIONMETHOD" = "xff";
      "VIKUNJA_SERVICE_TRUSTEDPROXIES" = "127.0.0.1/32,::1/128, 10.88.0.1/32";

      # Redis
      "VIKUNJA_REDIS_ENABLED" = "true";
      "VIKUNJA_REDIS_HOST" = "valkey:6379";
      "VIKUNJA_KEYVALUE_TYPE" = "redis";

      # OIDC Auth
      # Redirect(CallBack) URL format https://task.example.com/auth/openid/1
      "VIKUNJA_AUTH_LOCAL_ENABLED" = "false";
      "VIKUNJA_AUTH_OPENID_ENABLED" = "true";
      "VIKUNJA_AUTH_OPENID_PROVIDERS_1_NAME" = "";
      "VIKUNJA_AUTH_OPENID_PROVIDERS_1_AUTHURL" = "https://auth.example.com/oidc";
      "VIKUNJA_AUTH_OPENID_PROVIDERS_1_CLIENTID" = "xxxxxx";
      "VIKUNJA_AUTH_OPENID_PROVIDERS_1_CLIENTSECRET" = "xxxxxx";
      "VIKUNJA_AUTH_OPENID_PROVIDERS_1_SCOPE" = "openid profile email";
      "VIKUNJA_AUTH_OPENID_PROVIDERS_1_REQUIREAVAILABILITY" = "false";
    };
    volumes = [
      "vikunja:/app/vikunja/files:rw"
      # "/etc/vikunja/config.yml:/etc/vikunja/config.yml"
    ];
    ports = [
      "127.0.0.1:3456:3456/tcp"
    ];
  };

  systemd.services.create-pg-db-for-vikunja = {
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
        -c "CREATE ROLE vikunja WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE vikunja WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=vikunja;"
      '';
    };
  };
}
