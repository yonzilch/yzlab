_: {
  virtualisation.oci-containers.containers."forgejo" = {
    image = "codeberg.org/forgejo/forgejo:12";
    # environment = { # see https://forgejo.org/docs/latest/admin/config-cheat-sheet
      # "FORGEJO__database__DB_TYPE" = "postgres";
      # "FORGEJO__database__HOST" = "postgres:5432";
      # "FORGEJO__database__NAME" = "forgejo";
      # "FORGEJO__database__USER" = "forgejo";
      # "FORGEJO__database__PASSWD" = "xxxxxx";
    # };
    ports = [
      "127.0.0.1:43000:3000"
      "22:22"
    ];
    volumes = [
      "forgejo:/data:rw"
    ];
  };
}
