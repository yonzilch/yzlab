_: {
  virtualisation.oci-containers.containers."cobalt" = {
    image = "ghcr.io/imputnet/cobalt:latest";
    environment = {
      "API_INSTANCE_COUNT" = "1";
      "API_LISTEN_ADDRESS" = "0.0.0.0";
      "API_PORT" = "9000";
      "API_URL" = "https://cobalt.example.com/";
      # "API_REDIS_URL" = "redis://localhost:6379";
    };
    ports = [
      "127.0.0.1:19000:9000"
    ];
  };
}
