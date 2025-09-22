_: {
  virtualisation.oci-containers.containers."gotify" = {
    pull = "newer";
    image = "gotify/server:latest";
    environment = {
      GOTIFY_SERVER_PORT = "11180";
      GOTIFY_SERVER_KEEPALIVEPERIODSECONDS = "0";
      GOTIFY_SERVER_LISTENADDR = "";
      GOTIFY_SERVER_SSL_ENABLED = "false";
      GOTIFY_SERVER_STREAM_PINGPERIODSECONDS = "45";
      GOTIFY_DATABASE_DIALECT = "sqlite3";
      GOTIFY_DATABASE_CONNECTION = "data/gotify.db";
      GOTIFY_DEFAULTUSER_NAME = "foobar";
      GOTIFY_DEFAULTUSER_PASS = "xxxxxxxxxxxx";
      GOTIFY_PASSSTRENGTH = "10";
      GOTIFY_UPLOADEDIMAGESDIR = "data/images";
      GOTIFY_PLUGINSDIR = "data/plugins";
      GOTIFY_REGISTRATION = "false";
    };
    volumes = [
      "gotify:/data:rw"
    ];
    ports = [
      "127.0.0.1:11180:11180"
    ];
  };
}
