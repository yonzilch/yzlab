_: {
  virtualisation.oci-containers.containers."twonav" = {
    image = "tznb/twonav:latest";
    volumes = [
      "twonav:/www:rw"
    ];
    ports = [
      "127.0.0.1:9680:80"
    ];
  };
}
