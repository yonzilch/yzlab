_: {
  virtualisation.oci-containers.containers."vert" = {
    pull = "newer";
    image = "ghcr.io/vert-sh/vert:latest";
    ports = [
      "127.0.0.1:31023:80"
    ];
  };
}
