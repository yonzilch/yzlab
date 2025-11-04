_: {
  virtualisation.oci-containers.containers."photoprism" = {
    image = "photoprism/photoprism:latest";

    environment = {
      # 基本配置
      PHOTOPRISM_ADMIN_USER = "foobar";
      PHOTOPRISM_ADMIN_PASSWORD = "xxxxxx";

      PHOTOPRISM_DATABASE_DRIVER = "sqlite";

      PHOTOPRISM_HTTP_HOST = "0.0.0.0";
      PHOTOPRISM_HTTP_PORT = "2342";

      PHOTOPRISM_SITE_URL = "http://localhost:2342/";
      PHOTOPRISM_SITE_CAPTION = "This is your selfhosted PhotoPrism";

      PHOTOPRISM_READONLY = "false";
      PHOTOPRISM_UPLOAD_NSFW = "true";
      PHOTOPRISM_DETECT_NSFW = "false";
      PHOTOPRISM_EXPERIMENTAL = "false";
      PHOTOPRISM_DISABLE_TLS = "true";
      PHOTOPRISM_DISABLE_CHOWN = "false";
      PHOTOPRISM_DISABLE_WEBDAV = "false";

      PHOTOPRISM_LOG_LEVEL = "info";
    };
    volumes = [
      "photoprism_storage:/photoprism/storage:rw"
      "photoprism_originals:/photoprism/originals:rw"
    ];
    ports = [
      "127.0.0.1:2342:2342"
    ];
  };
}
