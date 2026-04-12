_: {
  virtualisation.oci-containers.containers."ech0" = {
    image = "ghcr.io/lin-snow/ech0:latest";
    pull = "newer";
    volumes = [
      "ech0:/app/data"
    ];
    environment = {
      JWT_SECRET = "xxxxxx";
    };

    ports = [
      "127.0.0.1:6277:6277"
    ];
  };
}
