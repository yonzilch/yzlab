{pkgs, ...}: {
  virtualisation.oci-containers.containers."forgejo" = {
    pull = "newer";
    user = "1000:1000";
    image = "codeberg.org/forgejo/forgejo:13-rootless";
    environment = {
      # see https://forgejo.org/docs/latest/admin/config-cheat-sheet
      USER_UID = "1000";
      USER_GID = "1000";
      FORGEJO__database__DB_TYPE = "postgres";
      FORGEJO__database__HOST = "postgres:5432";
      FORGEJO__database__NAME = "forgejo";
      FORGEJO__database__USER = "forgejo";
      FORGEJO__database__PASSWD = "xxxxxx";
    };
    volumes = [
      "forgejo_data:/data:rw"
      "forgejo_repo_conf:/etc/gitea:rw"
      "forgejo_repo_data:/var/lib/gitea:rw"
    ];
    ports = [
      "127.0.0.1:47162:3000"
      "22:2222"
    ];
  };

  systemd.services.create-pg-db-for-forgejo = {
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
        -c "CREATE ROLE forgejo WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE forgejo WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=forgejo;"
      '';
    };
  };
}
