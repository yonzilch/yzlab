_: {
  virtualisation.oci-containers.containers."komga" = {
    image = "gotson/komga:latest";
    environment = {
      JAVA_TOOL_OPTIONS = "-Xmx2g";
    };
    volumes = [
      "komga_config:/config:rw"
      "komga_data:/data:rw"
    ];
    ports = [
      "127.0.0.1:25600:25600"
    ];
  };
}
