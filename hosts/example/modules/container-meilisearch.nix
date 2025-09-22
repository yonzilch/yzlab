_: {
  virtualisation.oci-containers.containers = {
    meilisearch = {
      pull = "newer";
      image = "getmeili/meilisearch:v1.9.1";
      environment = {
        MEILI_MASTER_KEY = "xxxxxx";
      };
      volumes = [
        "meilisearch:/meili_data"
      ];
      ports = [
        "127.0.0.1:7700:7700"
      ];
    };
  };
}
