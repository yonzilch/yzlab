{pkgs, ...}: {
  virtualisation.oci-containers.containers."fusion" = {
    image = "ghcr.io/0x2e/fusion:latest";
    environment = {
      "HOST" = "0.0.0.0";
      "PORT" = "34921";
      "PASSWORD" = "xxxxxx";
    };
    ports = [
      "127.0.0.1:34921:34921/tcp"
    ];
  };
}
