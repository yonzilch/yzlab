_: {
  services.gotify = {
    enable = true;
    environment = {
      GOTIFY_DEFAULTUSER_NAME = "foobar";
      GOTIFY_DEFAULTUSER_PASS = "xxxxxx";
      GOTIFY_DATABASE_DIALECT = "sqlite3";
      GOTIFY_SERVER_PORT = "32105";
      GOTIFY_SERVER_SSL_ENABLED = "false";
    };
  };
}
