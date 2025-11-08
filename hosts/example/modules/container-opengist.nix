_: {
  virtualisation.oci-containers.containers."opengist" = {
    image = "ghcr.io/thomiceli/opengist:latest";
    volumes = [
      "opengist:/opengist:rw"
    ];
    ports = [
      "127.0.0.1:6157:6157"
      # "127.0.0.1:2222:2222" # SSH port, can be removed if you don't use SSH
    ];
  };
}
