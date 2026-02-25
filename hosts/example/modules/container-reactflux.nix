_: {
  virtualisation.oci-containers.containers."reactflux" = {
    pull = "newer";
    image = "electh/reactflux:latest";
    ports = [
      "127.0.0.1:51832:2000"
    ];
  };
}
