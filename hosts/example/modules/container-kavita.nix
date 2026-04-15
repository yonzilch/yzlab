_: {
  virtualisation.oci-containers.containers."kavita" = {
    image = "lscr.io/linuxserver/kavita:latest";
    volumes = [
      "kavita_config:/config:rw"
      "kavita_book:/kavita/book:rw"
      "kavita_comic:/kavita/comic:rw"
      "kavita_image:/kavita/image:rw"
      "kavita_lightnovel:/kavita/lightnovel:rw"
    ];
    ports = [
      "127.0.0.1:5000:5000"
    ];
  };
}
