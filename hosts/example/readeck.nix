_: {
  services.readeck = {
    enable = true;
    settings = {
      main = {
        log_level = "warn";
        secret_key = "xxxxxx";
      };
      server = {
        host = "0.0.0.0";
        port = 8000;
      };
    };
  };
}
