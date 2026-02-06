_: {
  virtualisation.oci-containers.containers."blackcandy" = {
    pull = "newer";
    image = "ghcr.io/blackcandy-org/blackcandy:latest";
    environment = {
      # DB_ADAPTER = "postgresql";
      # DB_URL = "postgresql://yourdatabaseurl";
      MEDIA_PATH = "/media_data";
    };
    ports = [
      "127.0.0.1:59421:3000"
    ];
    volumes = [
      "blackcandy_storage:/app/storage"
      "blackcandy_media_data:/media_data"
    ];
  };
}
