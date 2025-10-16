_: {
  virtualisation.oci-containers.containers."readeck" = {
    image = "codeberg.org/readeck/readeck:latest";
    volumes = [
      "readeck:/readeck:rw"
    ];
    ports = [
      "127.0.0.1:8000:8000"
    ];
  };
}
