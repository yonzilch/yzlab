{ ... }: {
  virtualisation.oci-containers.containers."omniroute" = {
    pull = "newer";
    image = "diegosouzapw/omniroute:latest";
    environment = [
      # see https://github.com/diegosouzapw/OmniRoute/blob/main/docs/reference/ENVIRONMENT.md
    ];
    volumes = [
      "omniroute:/app/data:rw"
    ];
    ports = [
      "127.0.0.1:20128:20128"
    ];
  };
}
