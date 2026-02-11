_: {
  virtualisation.oci-containers.containers."rustfs" = {
    # see https://github.com/rustfs/rustfs
    image = "rustfs/rustfs:latest";
    environment = {
      RUSTFS_ADDRESS = "0.0.0.0:9000";
      RUSTFS_CONSOLE_ADDRESS = "0.0.0.0:9001";
      RUSTFS_CONSOLE_ENABLE = "true";
      RUSTFS_CORS_ALLOWED_ORIGINS = "*";
      RUSTFS_CONSOLE_CORS_ALLOWED_ORIGINS = "*";
      RUSTFS_ACCESS_KEY = "xxxxxx";
      RUSTFS_SECRET_KEY = "xxxxxxxxxxxx";
    };
    volumes = [
      "rustfs_data:/data"
      "rustfs_logs:/logs"
    ];
    ports = [
      "127.0.0.1:9000:9000" # S3 API port
      "127.0.0.1:9001:9001" # Console port
    ];
  };
}
