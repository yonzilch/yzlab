_: {
  virtualisation.oci-containers.containers."dumb" = {
    image = "ghcr.io/rramiachraf/dumb:latest";
    ports = [
      "127.0.0.1:5555:5555"
    ];
  };
}
