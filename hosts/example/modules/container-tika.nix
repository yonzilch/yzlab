_: {
  virtualisation.oci-containers.containers."tika" = {
    image = "docker.io/apache/tika:latest";
    pull = "newer";

    ports = [
      "127.0.0.1:9998:9998"
    ];
  };
}
