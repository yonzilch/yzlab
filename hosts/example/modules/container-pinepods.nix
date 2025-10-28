_ : {
  virtualisation.oci-containers.containers = {
    "pinepods" = {
      image = "madeofpendletonwool/pinepods:latest";
      environment = {
        HOSTNAME = "http://localhost:8040";
        DB_TYPE = "postgresql";
        DB_HOST = "postgres";
        DB_PORT = "5432";
        DB_USER = "pinepods";
        DB_PASSWORD = "xxxxxx";
        DB_NAME = "pinepods";
        VALKEY_HOST = "pogocache";
        VALKEY_PORT = "9401";
        DEBUG_MODE = "false";
        SEARCH_API_URL = "http://pinepods-search-api/api/search";
        PEOPLE_API_URL = "https://people.pinepods.online";
      };
      volumes = [
        "pinepods:/opt/pinepods:rw"
      ];
      ports = [
        "127.0.0.1:8040:8040"
      ];
    };

    pinepods-search-api = {
      image = "madeofpendletonwool/pinepods_backend:latest";
      environment = {
        API_KEY = "your_podcastindex_api_key";
        API_SECRET = "your_podcastindex_api_secret";
        YOUTUBE_API_KEY = "your_youtube_api_key";
        RUST_LOG = "info";
      };
      ports = [
        "127.0.0.1:5000:5000"
      ];
    };
  };
}
