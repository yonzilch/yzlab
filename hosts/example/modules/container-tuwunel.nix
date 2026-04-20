_: {
  virtualisation.oci-containers.containers."tuwunel" = {
    image = "ghcr.io/matrix-construct/tuwunel:latest";
    pull = "newer";

    environment = {
      TUWUNEL_SERVER_NAME = "matrix.example.com";
      TUWUNEL_REGISTRATION_TOKEN = "xxxxxx";
      TUWUNEL_DATABASE_PATH = "/var/lib/tuwunel";
      TUWUNEL_ADDRESS = "0.0.0.0";
      TUWUNEL_PORT = "8008";
      TUWUNEL_WELL_KNOWN__CLIENT = "https://matrix.example.com";
      TUWUNEL_WELL_KNOWN__SERVER = "matrix.example.com:443";
      TUWUNEL_WELL_KNOWN__LIVEKIT_URL = "https://livekit.example.com";

      TUWUNEL_ALLOW_REGISTRATION = "true";
      TUWUNEL_ALLOW_FEDERATION = "true";
      TUWUNEL_ALLOW_LEGACY_MEDIA = "true";
      TUWUNEL_REQUEST_LEGACY_MEDIA = "true";

      TUWUNEL_MAX_REQUEST_SIZE = "25165824"; # 24 MiB，单位 bytes

      TUWUNEL_LOG = "info";
      TUWUNEL_LOG_COLORS = "true";

      TUWUNEL_ALLOW_ENCRYPTION = "true";
      TUWUNEL_ALLOW_ROOM_CREATION = "true";

      TUWUNEL_ALLOW_LOCAL_PRESENCE = "true";
      TUWUNEL_ALLOW_INCOMING_PRESENCE = "true";
      TUWUNEL_ALLOW_OUTGOING_PRESENCE = "true";

      TUWUNEL_ROCKSDB_COMPRESSION_ALGO = "zstd";

      ## OIDC
      # "TUWUNEL_IDENTITY_PROVIDER__0__BRAND" = "keycloak";
      # "TUWUNEL_IDENTITY_PROVIDER__0__CLIENT_ID" = "";
      # "TUWUNEL_IDENTITY_PROVIDER__0__CLIENT_SECRET" = "";
      # "TUWUNEL_IDENTITY_PROVIDER__0__ISSUER_URL" = "https://auth.example.com/oidc";
      # "TUWUNEL_IDENTITY_PROVIDER__0__NAME" = "";
      # "TUWUNEL_IDENTITY_PROVIDER__0__DEFAULT" = "true";
      # "TUWUNEL_IDENTITY_PROVIDER__0__DISCOVERY" = "true";
      ## S3
      # "TUWUNEL_STORAGE_PROVIDER__MEDIA_ON_S3__S3__BUCKET" = "matrix";
      # "TUWUNEL_STORAGE_PROVIDER__MEDIA_ON_S3__S3__URL" = "s3://matrix";
      # "TUWUNEL_STORAGE_PROVIDER__MEDIA_ON_S3__S3__KEY" = "xxxxxx";
      # "TUWUNEL_STORAGE_PROVIDER__MEDIA_ON_S3__S3__SECRET" = "xxxxxx";
      # "TUWUNEL_STORAGE_PROVIDER__MEDIA_ON_S3__S3__ENDPOINT" = "https://s3.example.com";
      # "TUWUNEL_STORAGE_PROVIDER__MEDIA_ON_S3__S3__USE_VHOST_REQUEST" = "false";
      # "TUWUNEL_STORAGE_PROVIDER__MEDIA_ON_S3__S3__REGION" = "xxxxxx";
      # "TUWUNEL_STORE_MEDIA_ON_PROVIDERS" = "[\"media_on_s3\"]";
      # "TUWUNEL_MEDIA_STORAGE_PROVIDERS" = "[\"media_on_s3\"]";
    };

    volumes = [
      "tuwunel:/var/lib/tuwunel"
    ];

    ports = [
      "127.0.0.1:8008:8008"
    ];
  };
}
