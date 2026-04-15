_: {
  virtualisation.oci-containers.containers."calibre-web-automated" = {
    image = "crocodilestick/calibre-web-automated:latest";
    pull = "newer";
    environment = {
      "PUID" = "1000";
      "PGID" = "1000";
      "TZ" = "Asia/Singapore";
      "CWA_PORT_OVERRIDE" = "8083";
      "NETWORK_SHARE_MODE" = "false";
      "SECRET_KEY" = "xxxxxx";
      # "TRUSTED_PROXY_COUNT" = "255";
      # "OAUTHLIB_INSECURE_TRANSPORT" = "1";
      # "OAUTHLIB_RELAX_TOKEN_SCOPE" = "1";
      # "HARDCOVER_TOKEN" = "";
    };
    volumes = [
      "calibre-web-automated_config:/config"
      "calibre-web-automated_cwa-book-ingest:/cwa-book-ingest"
      "calibre-web-automated_calibre-library:/calibre-library"
    ];
    ports = [
      "127.0.0.1:46193:8083/tcp"
    ];
  };
}
