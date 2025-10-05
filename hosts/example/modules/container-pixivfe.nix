_: {
  virtualisation.oci-containers.containers."pixivfe" = {
    image = "registry.gitlab.com/pixivfe/pixivfe:latest";
    # see https://pixivfe-docs.pages.dev/configuration-options
    environment = {
      "PIXIVFE_HOST" = "0.0.0.0";
      "PIXIVFE_PORT" = "8282";
      # "PIXIVFE_TOKEN" = "token1,token2,token3";
      # "PIXIVFE_IMAGEPROXY" = "";
      # "PIXIVFE_STATICPROXY" = "";
      # "PIXIVFE_UGOIRAPROXY" = "";
    };
    volumes = [
      "pixivfe:/app/data:rw"
    ];
    ports = [
      "127.0.0.1:8282:8282"
    ];
  };
}
