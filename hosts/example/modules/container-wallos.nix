_: {
  virtualisation.oci-containers.containers."wallos" = {
    image = "ghcr.io/ellite/wallos:latest";

    volumes = [
      "wallos_db:/var/www/html/db:rw"
      "wallos_logos:/var/www/html/images/uploads/logos:rw"
    ];

    ports = [
      "127.0.0.1:47085:80"
    ];
  };
}
