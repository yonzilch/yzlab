{pkgs, ...}: {
  systemd.services.create-pg-db-for-synapse = {
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
        -c "CREATE ROLE immich WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE immich WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=immich;"
      '';
    };
  };

  environment.etc."immich/.env" = {
    mode = "0644";
    text = ''
      # You can find documentation for all the supported env variables at https://docs.immich.app/install/environment-variables

      # The location where your uploaded files are stored
      UPLOAD_LOCATION=./library

      # The location where your database files are stored. Network shares are not supported for the database
      DB_DATA_LOCATION=./postgres

      # To set a timezone, uncomment the next line and change Etc/UTC to a TZ identifier from this list: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List
      # TZ=Etc/UTC

      # The Immich version to use. You can pin this to a specific version like "v2.1.0"
      IMMICH_VERSION=v2

      # Connection secret for postgres. You should change it to a random password
      # Please use only the characters `A-Za-z0-9`, without special characters or spaces
      DB_PASSWORD=postgres

      # The values below this line do not need to be changed
      ###################################################################################
      DB_USERNAME=postgres
      DB_DATABASE_NAME=immich
    '';
  };
  virtualisation.oci-containers.containers = {
    "immich" = {
      image = "ghcr.io/imagegenius/immich:latest";
      environmentFiles = [/etc/immich/.env];
      ports = [
        "127.0.0.1:2283:2283"
      ];
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "immich:/data:rw"
      ];
    };

    "immich-machine-learning" = {
      image = "ghcr.io/imagegenius/immich:latest";
      environmentFiles = [/etc/immich/.env];
      ports = [
        "127.0.0.1:3003:3003"
      ];
    };
    volumes = [
      "immich-model-cache:/cache:rw"
    ];
  };
}
