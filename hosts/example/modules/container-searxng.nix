_: {
  virtualisation.oci-containers.containers.searxng = {
    image = "searxng/searxng:latest";
    ports = [
      "127.0.0.1:32768:8080"
    ];
    environment = {
      SEARXNG_BASE_URL = "https://search.example.com";
    };
    volumes = [
      "searxng:/etc/searxng"
    ];
  };
}
