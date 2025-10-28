_: {
  virtualisation.oci-containers.containers."kavita" = {
    image = "lscr.io/linuxserver/kavita:latest";
    volumes = [
      "kavita_config:/config:rw"
      "kavita_data:/data:rw"
    ];
    ports = [
      "127.0.0.1:5000:5000"
    ];
  };
}
