{pkgs, ...}: {
  virtualisation.oci-containers.containers."casdoor" = {
    pull = "newer";
    image = "casbin/casdoor:latest";

    dependsOn = [
      "keydb"
      "postgres"
    ];

    volumes = [
      "casdoor_conf:/conf:rw"
      "casdoor_logs:/logs:rw"
    ];

    ports = [
      "127.0.0.1:8000:8000"
    ];
    user = "1000:1000";

    environment = {
      # see https://casdoor.org/docs/basic/configuration/#backend-configuration-appconf
      RUNNING_IN_DOCKER = "true";
      dbName = "casdoor";
      dataSourceName = "user=casdoor password=xxxxxx host=postgres port=5432 sslmode=disable dbname=casdoor";
      driverName = "postgres";
      redisEndpoint = "keydb:6379";
      runmode = "prod";
    };
  };

  systemd.services.create-pg-db-for-casdoor = {
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
        -c "CREATE ROLE casdoor WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE casdoor WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=casdoor;"
      '';
    };
  };
}
