_: {
  virtualisation.oci-containers.containers."cyberchef" = {
    pull = "newer";
    image = "ghcr.io/gchq/cyberchef:latest";
    ports = [
      "127.0.0.1:43091:80"
    ];
  };
}
