_: {
  virtualisation.oci-containers.containers."yaade" = {
    image = "esperotech/yaade:latest";
    pull = "newer";
    environment = {
      "YAADE_ADMIN_USERNAME" = "admin";
      # "YAADE_BASE_PATH" = "/yaade";
    };
    ports = [
      "127.0.0.1:39451:9339/tcp"
    ];
    volumes = [
      "yaade:/app/data"
    ];
  };
}
