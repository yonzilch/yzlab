_: {
  virtualisation.oci-containers.containers."it-tools" = {
    pull = "newer";
    image = "ghcr.io/sharevb/it-tools:stable";
    ports = [
      "127.0.0.1:46137:8080"
    ];
  };
}
