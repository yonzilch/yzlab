_: {
  virtualisation.oci-containers.containers."wakapi" = {
    image = "ghcr.io/muety/wakapi:latest";

    environment = {
      # App Settings
      WAKAPI_LEADERBOARD_ENABLED = "true";
      WAKAPI_LEADERBOARD_SCOPE = "7_days";
      WAKAPI_LEADERBOARD_GENERATION_TIME = "0 0 6 * * *,0 0 18 * * *";
      WAKAPI_LEADERBOARD_REQUIRE_AUTH = "false";
      WAKAPI_AGGREGATION_TIME = "0 15 2 * * *";
      WAKAPI_REPORT_TIME_WEEKLY = "0 0 18 * * 5";
      WAKAPI_DATA_CLEANUP_TIME = "0 0 6 * * 0";
      WAKAPI_OPTIMIZE_DATABASE_TIME = "0 0 8 1 * *";

      # Import Settings
      WAKAPI_IMPORT_ENABLED = "true";
      WAKAPI_IMPORT_BATCH_SIZE = "50";
      WAKAPI_IMPORT_BACKOFF_MIN = "5";
      WAKAPI_IMPORT_MAX_RATE = "24";

      # Data Settings
      WAKAPI_INACTIVE_DAYS = "7";
      WAKAPI_HEARTBEAT_MAX_AGE = "4320h";
      WAKAPI_WARM_CACHES = "true";
      WAKAPI_DATA_RETENTION_MONTHS = "-1";
      WAKAPI_MAX_INACTIVE_MONTHS = "12";

      # UI Settings
      WAKAPI_AVATAR_URL_TEMPLATE = "https://api.dicebear.com/7.x/initials/svg?seed={username}";
      WAKAPI_DATE_FORMAT = "Mon, 02 Jan 2006";
      WAKAPI_DATETIME_FORMAT = "Mon, 02 Jan 2006 15:04";
      WAKAPI_SUPPORT_CONTACT = "admin@example.com";

      # Server Settings
      WAKAPI_PORT = "3000";
      WAKAPI_LISTEN_IPV4 = "0.0.0.0";
      WAKAPI_LISTEN_IPV6 = "-";
      WAKAPI_LISTEN_SOCKET = "-";
      WAKAPI_TIMEOUT_SEC = "30";
      WAKAPI_BASE_PATH = "/";
      WAKAPI_PUBLIC_URL = "http://localhost:46316";

      # Security Settings
      WAKAPI_PASSWORD_SALT = "your-secure-random-salt-here";
      WAKAPI_INSECURE_COOKIES = "false";
      WAKAPI_COOKIE_MAX_AGE = "172800";
      WAKAPI_ALLOW_SIGNUP = "true";
      WAKAPI_SIGNUP_CAPTCHA = "false";
      WAKAPI_INVITE_CODES = "false";
      WAKAPI_DISABLE_FRONTPAGE = "false";
      WAKAPI_EXPOSE_METRICS = "false";

      # Authentication
      WAKAPI_TRUSTED_HEADER_AUTH = "false";
      WAKAPI_TRUSTED_HEADER_AUTH_KEY = "Remote-User";
      WAKAPI_TRUSTED_HEADER_AUTH_ALLOW_SIGNUP = "false";

      # Rate Limiting
      WAKAPI_SIGNUP_MAX_RATE = "5/1h";
      WAKAPI_LOGIN_MAX_RATE = "10/1m";
      WAKAPI_PASSWORD_RESET_MAX_RATE = "5/1h";

      # Database Settings (SQLite default)
      WAKAPI_DB_TYPE = "sqlite3";
      WAKAPI_DB_NAME = "/data/wakapi.db";
      WAKAPI_DB_MAX_CONNECTIONS = "2";
      WAKAPI_DB_AUTOMIGRATE_FAIL_SILENTLY = "false";

      # Mail Settings (disabled by default)
      WAKAPI_MAIL_ENABLED = "false";
      WAKAPI_MAIL_SENDER = "noreply@example.com";
      WAKAPI_MAIL_SKIP_VERIFY_MX_RECORD = "false";
      WAKAPI_MAIL_PROVIDER = "smtp";

      # Sentry (disabled by default)
      WAKAPI_SENTRY_DSN = "";
      WAKAPI_SENTRY_TRACING = "false";

      # Development
      WAKAPI_QUICK_START = "false";
      WAKAPI_ENABLE_PPROF = "false";
    };

    volumes = [
      "wakapi:/data:rw"
    ];

    ports = [
      "127.0.0.1:46316:3000"
    ];
  };
}
