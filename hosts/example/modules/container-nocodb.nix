_: {
  virtualisation.oci-containers.containers."nocodb" = {
    image = "nocodb/nocodb:latest";
    volumes = [
      "nocodb:/usr/app/data:rw"
    ];
    ports = [
      "127.0.0.1:59173:8080"
    ];
  };
}
