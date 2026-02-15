{pkgs, ...}: {
  virtualisation.oci-containers.containers."grist" = {
    image = "gristlabs/grist:latest";

    environment = {
      ASSISTANT_CHAT_COMPLETION_ENDPOINT = "";
      ASSISTANT_API_KEY = "xxxxxx";
      APP_HOME_URL = "https://grist.example.com";
      GRIST_DEFAULT_EMAIL = "foobar@example.com";
      GRIST_SINGLE_ORG = "foobar";
      GRIST_SANDBOX_FLAVOR = "gvisor";
      GRIST_FORCE_LOGIN = "false";
      GRIST_SESSION_SECRET = "xxxxxx";

      GRIST_OIDC_IDP_ISSUER = "";
      GRIST_OIDC_IDP_CLIENT_ID = "";
      GRIST_OIDC_IDP_CLIENT_SECRET = "";
      GRIST_OIDC_IDP_END_SESSION_ENDPOINT = "";

      GRIST_LOG_LEVEL = "info";

      REDIS_URL = "redis://valkey";

      TYPEORM_DATABASE = "grist";
      TYPEORM_USERNAME = "grist";
      TYPEORM_HOST = "pgroonga";
      TYPEORM_LOGGING = "false";
      TYPEORM_PASSWORD = "xxxxxx";
      TYPEORM_PORT = "5432";
      TYPEORM_TYPE = "postgres";
    };

    volumes = [
      "grist:/persist"
    ];

    ports = [
      "127.0.0.1:8484:8484"
    ];
  };

  systemd.services.create-pg-db-for-grist = {
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
        ${pkgs.podman}/bin/podman exec -i pgroonga \
        psql -U postgres \
        -c "CREATE ROLE grist WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE grist WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=grist;"
      '';
    };
  };
}
