_: {
  virtualisation.oci-containers.containers."convertx" = {
    image = "ghcr.io/c4illin/convertx:latest";
    volumes = [
      "convertx:/app/data:rw"
    ];
    ports = [
      "127.0.0.1:42891:3000"
    ];
  };
}
