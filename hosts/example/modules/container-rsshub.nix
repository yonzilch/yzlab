_: {
  virtualisation.oci-containers.containers."rsshub" = {
    image = "ghcr.io/diygod/rsshub:latest";
    environment = {
      "PORT" = "11200";
    };
    ports = [
      "127.0.0.1:11200:11200"
    ];
  };
}
