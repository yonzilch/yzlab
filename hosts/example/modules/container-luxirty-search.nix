_: {
  virtualisation.oci-containers.containers."luxirty-search" = {
    image = "ghcr.io/koriiku/luxirty-search";
    ports = [
      "127.0.0.1:10080:80"
    ];
  };
}
