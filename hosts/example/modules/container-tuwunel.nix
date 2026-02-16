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

      TUWUNEL_ALLOW_REGISTRATION = "true";
      TUWUNEL_ALLOW_FEDERATION = "true";
      TUWUNEL_WELL_KNOWN__CLIENT = "https://matrix.example.com";
      TUWUNEL_WELL_KNOWN__SERVER = "matrix.example.com:443";

      TUWUNEL_MAX_REQUEST_SIZE = "25165824"; # 24 MiB，单位 bytes
      TUWUNEL_ALLOW_LEGACY_MEDIA = "false";

      TUWUNEL_LOG = "debug";
      TUWUNEL_LOG_COLORS = "false";

      TUWUNEL_ALLOW_ENCRYPTION = "true";
      TUWUNEL_ALLOW_ROOM_CREATION = "true";

      TUWUNEL_ALLOW_LOCAL_PRESENCE = "true";
      TUWUNEL_ALLOW_INCOMING_PRESENCE = "true";
      TUWUNEL_ALLOW_OUTGOING_PRESENCE = "true";

      TUWUNEL_ROCKSDB_COMPRESSION_ALGO = "zstd";

      # "TUWUNEL_IDENTITY_PROVIDER__0__BRAND" = "keycloak";
      # "TUWUNEL_IDENTITY_PROVIDER__0__CLIENT_ID" = "";
      # "TUWUNEL_IDENTITY_PROVIDER__0__CLIENT_SECRET" = "";
      # "TUWUNEL_IDENTITY_PROVIDER__0__ISSUER_URL" = "https://auth.example.com/oidc";
      # "TUWUNEL_IDENTITY_PROVIDER__0__NAME" = "";
      # "TUWUNEL_IDENTITY_PROVIDER__0__DEFAULT" = "true";
      # "TUWUNEL_IDENTITY_PROVIDER__0__DISCOVERY" = "true";
    };

    volumes = [
      "tuwunel:/var/lib/tuwunel"
    ];

    ports = [
      "127.0.0.1:8008:8008"
    ];
  };
}
