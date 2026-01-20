_: {
  virtualisation.oci-containers.containers."webp-server-go" = {
    pull = "newer";
    image = "ghcr.io/webp-sh/webp_server_go:latest";
    environment = {
      WEBP_QUALITY = "80";
      # WEBP_IMG_PATH = "https://static.example.com";
    };
    ports = [
      "127.0.0.1:3333:3333"
    ];
    volumes = [
      # "/etc/webp-server-go/config.json:/etc/config.json" # see https://docs.webp.sh/usage/configuration
      "webp-server-go_exhaust:/opt/exhaust:rw"
      "webp-server-go_metadata:/opt/metadata:rw"
      "webp-server-go_pics:/opt/pics"
    ];
  };
}
