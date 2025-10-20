_: {
  virtualisation.oci-containers.containers."microbin" = {
    image = "danielszabo99/microbin:latest";
    environment = {
      MICROBIN_ADMIN_USERNAME = "foobar";
      MICROBIN_ADMIN_PASSWORD = "xxxxxx";
      MICROBIN_DISABLE_TELEMETRY = "true";
      MICROBIN_ENABLE_BURN_AFTER = "true";
      MICROBIN_HASH_IDS = "true";
      MICROBIN_HIDE_FOOTER = "true";
      MICROBIN_MAX_FILE_SIZE_ENCRYPTED_MB = "100";
      MICROBIN_MAX_FILE_SIZE_UNENCRYPTED_MB = "100";
      MICROBIN_NO_LISTING = "true";
      MICROBIN_PUBLIC_PATH = "https://bin.example.com/";
      MICROBIN_TITLE = "BIN | EXAMPLE";
      MICROBIN_UPLOADER_PASSWORD = "xxxxxx";
    };
    volumes = [
      "microbin:/app/microbin_data:rw"
    ];
    ports = [
      "127.0.0.1:36492:8080"
    ];
  };
}
