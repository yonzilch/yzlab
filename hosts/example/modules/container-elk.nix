_: {
  virtualisation.oci-containers.containers."elk" = {
    image = "ghcr.io/elk-zone/elk:latest";
    user = "911:911";
    ports = [
      "127.0.0.1:5314:5314"
    ];
    volumes = [
      "elk:/elk/data"
    ];
  };
}
