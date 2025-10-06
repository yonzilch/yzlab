_: {
  virtualisation.oci-containers.containers."beatbump" = {
    image = "ghcr.io/giwty/beatbump:latest";
    ports = [
      "127.0.0.1:33301:8080"
    ];
  };
}
