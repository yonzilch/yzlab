_: {
  virtualisation.oci-containers.containers."komf" = {
    image = "sndxf/komf:latest";
    environment = {
      KOMF_KOMGA_BASE_URI = "http://komga:25600";
      KOMF_KOMGA_USER = "admin@example.org";
      KOMF_KOMGA_PASSWORD = "admin";
      KOMF_KAVITA_BASE_URI = "http://kavita:5000";
      KOMF_KAVITA_API_KEY = "16707507-d05d-4696-b126-c3976ae14ffb";
      KOMF_LOG_LEVEL = "INFO";
    };
    volumes = [
      "komf_config:/config:rw"
    ];
    ports = [
      "127.0.0.1:8085:8085"
    ];
  };
}
