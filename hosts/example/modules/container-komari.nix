_: {
  virtualisation.oci-containers.containers."komari" = {
    pull = "newer";
    image = "ghcr.io/komari-monitor/komari:latest";
    ports = [
      "127.0.0.1:25774:25774"
    ];
    volumes = [
      "komari:/app/data"
    ];
  };
}
