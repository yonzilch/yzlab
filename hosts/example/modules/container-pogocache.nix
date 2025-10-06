_: {
  virtualisation.oci-containers.containers."pogocache" = {
    image = "pogocache/pogocache:latest";
    ports = [
      "127.0.0.1:6379:9401"
    ];
  };
}
