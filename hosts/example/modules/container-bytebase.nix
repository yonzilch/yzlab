_: {
  virtualisation.oci-containers.containers."bytebase" = {
    image = "bytebase/bytebase:latest";
    ports = [
      "127.0.0.1:58080:8080"
    ];
    volumes = [
      "bytebase:/var/opt/bytebase:rw"
    ];
  };
}
