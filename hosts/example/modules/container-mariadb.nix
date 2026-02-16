_: {
  virtualisation.oci-containers.containers."mariadb" = {
    image = "lscr.io/linuxserver/mariadb:latest";
    pull = "newer";

    environment = {
      PUID = "1000";
      PGID = "1000";
      MYSQL_ROOT_PASSWORD = "xxxxxx";
    };

    volumes = [
      "mariadb:/config"
    ];

    ports = [
      "127.0.0.1:3306:3306"
    ];
  };
}
