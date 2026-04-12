{pkgs, ...}: {
  # rote-backend
  virtualisation.oci-containers.containers."rote-backend" = {
    image = "rabithua/rote-backend:latest";
    entrypoint = "sh";
    cmd = [
      "-c"
      "sleep 15 && bun run dist/scripts/runMigrations.js && bun run dist/server.js"
    ];
    environment = {
      "POSTGRESQL_URL" = "postgresql://rote:xxxxxx@postgres:5432/rote";
    };
    ports = [
      "127.0.0.1:58011:3000"
    ];
    dependsOn = ["postgres"];
  };

  # rote-frontend
  virtualisation.oci-containers.containers."rote-frontend" = {
    image = "rabithua/rote-frontend:latest";
    environment = {
      "VITE_API_BASE" = "https://rote-backend.example.com";
    };
    ports = [
      "127.0.0.1:58012:80"
    ];
    dependsOn = ["rote-backend"];
  };

  systemd.services.create-pg-db-for-rote = {
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
        -c "CREATE ROLE rote WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE rote WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=rote;"
      '';
    };
  };
}
