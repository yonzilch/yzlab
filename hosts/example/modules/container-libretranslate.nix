_: {
  virtualisation.oci-containers.containers."libretranslate" = {
    image = "libretranslate/libretranslate:latest";
    ports = [
      "127.0.0.1:15000:5000"
    ];
  };
}
