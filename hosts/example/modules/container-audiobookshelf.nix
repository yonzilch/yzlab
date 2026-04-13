_: {
  virtualisation.oci-containers.containers."audiobookshelf" = {
    image = "ghcr.io/advplyr/audiobookshelf:latest";
    pull = "newer";
    environment = {
      "TZ" = "Asia/Singapore";
      "CONFIG_PATH" = "/config";
      "METADATA_PATH" = "/metadata";
    };
    volumes = [
      "audiobookshelf_audiobooks:/audiobooks"
      "audiobookshelf_podcasts:/podcasts"
      "audiobookshelf_config:/config"
      "audiobookshelf_metadata:/metadata"
    ];
    ports = [
      "127.0.0.1:43149:80/tcp"
    ];
  };
}
