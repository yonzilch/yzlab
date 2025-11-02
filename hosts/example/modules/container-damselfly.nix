_: {
  virtualisation.oci-containers.containers."damselfly" = {
    image = "webreaper/damselfly:latest";
    volumes = [
      "damselfly_config:/config:rw"
      "damselfly_thumbs:/thumbs:rw"
      "damselfly_pictures:/pictures:rw"
    ];
    ports = [
      # "127.0.0.1:6363:6363"
    ];
  };
}
