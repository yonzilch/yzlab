_: {
  services.homebox = {
    enable = true;
    settings = {
      HBOX_STORAGE_CONN_STRING = "file:///var/lib/homebox/data";
      HBOX_DATABASE_DRIVER = "sqlite3";
      HBOX_DATABASE_SQLITE_PATH = "/var/lib/homebox/data/homebox.db?_pragma=busy_timeout=999&_pragma=journal_mode=WAL&_fk=1";
      HBOX_OPTIONS_ALLOW_REGISTRATION = "false";
      HBOX_OPTIONS_CHECK_GITHUB_RELEASE = "false";
      HBOX_MODE = "production";
    };
  };
  systemd.services.homebox = {
    environment = {
      HOME = "/var/lib/homebox";
    };
  };
}
