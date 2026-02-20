{...}: {
  virtualisation.oci-containers.containers."manticore" = {
    image = "manticoresearch/manticore:10.1.0-hf";
    pull = "newer";

    volumes = [
      "manticore:/var/lib/manticore"
    ];

    ports = [
      "127.0.0.1:9308:9308"
    ];

    extraOptions = [
      # Increase resource limits to handle larger indexes / higher concurrency
      "--ulimit=nproc=65535:65535"
      "--ulimit=nofile=65535:65535"
      "--ulimit=memlock=-1:-1"
    ];
  };
}
