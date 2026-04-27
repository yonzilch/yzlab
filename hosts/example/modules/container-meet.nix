{pkgs, ...}: let
  MEET_HOST = "meet.example.com";
  LIVEKIT_HOST = "livekit.example.com";
  BACKEND_INTERNAL_HOST = "meet-backend";
  FRONTEND_INTERNAL_HOST = "meet-frontend";
  LIVEKIT_API_KEY = "";
  LIVEKIT_API_SECRET = "";
  DB_PASSWORD = "xxxxxx";
  DJANGO_SUPERUSER_EMAIL = "foobar@example.com";
  DJANGO_SUPERUSER_PASSWORD = "xxxxxx";

  sharedEnv = {
    # Host settings
    MEET_HOST = MEET_HOST;
    LIVEKIT_HOST = LIVEKIT_HOST;
    BACKEND_INTERNAL_HOST = BACKEND_INTERNAL_HOST;
    FRONTEND_INTERNAL_HOST = FRONTEND_INTERNAL_HOST;
    LIVEKIT_INTERNAL_HOST = "livekit";
    REDIS_URL = "redis://valkey:6379/11";

    # DB settings
    DB_HOST = "postgres";
    DB_NAME = "meet";
    DB_USER = "meet";
    DB_PASSWORD = DB_PASSWORD;
    DB_PORT = "5432";

    # Django
    DJANGO_ALLOWED_HOSTS = "${MEET_HOST}";
    DJANGO_SECRET_KEY = "xxxxxx";
    DJANGO_SETTINGS_MODULE = "meet.settings";
    DJANGO_CONFIGURATION = "Production";
    DJANGO_SUPERUSER_EMAIL = DJANGO_SUPERUSER_EMAIL;
    DJANGO_SUPERUSER_PASSWORD = DJANGO_SUPERUSER_PASSWORD;

    # Python
    PYTHONPATH = "/app";

    # Backend url
    MEET_BASE_URL = "https://${MEET_HOST}";

    # OIDC
    # Callback URL: https://${MEET_HOST}/api/v1.0/callback/
    # PostLogout URL: https://${MEET_HOST}/api/v1.0/logout-callback/
    OIDC_OP_JWKS_ENDPOINT = "https://auth.example.com/oidc/jwks";
    OIDC_OP_AUTHORIZATION_ENDPOINT = "https://auth.example.com/oidc/auth";
    OIDC_OP_TOKEN_ENDPOINT = "https://auth.example.com/oidc/token";
    OIDC_OP_USER_ENDPOINT = "https://auth.example.com/oidc/me";
    OIDC_OP_LOGOUT_ENDPOINT = "https://auth.example.com/oidc/session/end";
    OIDC_USE_PKCE = "false";
    OIDC_RP_CLIENT_ID = "xxxxxx";
    OIDC_RP_CLIENT_SECRET = "xxxxxx";
    OIDC_RP_SIGN_ALGO = "RS256";
    OIDC_RP_SCOPES = "openid email";
    LOGIN_REDIRECT_URL = "https://${MEET_HOST}";
    LOGIN_REDIRECT_URL_FAILURE = "https://${MEET_HOST}";
    LOGOUT_REDIRECT_URL = "https://${MEET_HOST}";
    OIDC_REDIRECT_ALLOWED_HOSTS = ''["https://${MEET_HOST}"]'';
    # KEYCLOAK_HOST = ""; # For keycloak
    # REALM_NAME = ""; # For keycloak

    # Livekit Token settings
    LIVEKIT_API_KEY = LIVEKIT_API_KEY;
    LIVEKIT_API_SECRET = LIVEKIT_API_SECRET;
    LIVEKIT_API_URL = "https://${LIVEKIT_HOST}";

    # App settings
    ALLOW_UNREGISTERED_ROOMS = "True";
  };

  defaultConfTemplate = pkgs.writeTextFile {
    name = "default.conf.template";
    text = ''
      upstream meet_backend {
          server ${BACKEND_INTERNAL_HOST}:8000 fail_timeout=0;
      }
      upstream meet_frontend {
          server ${FRONTEND_INTERNAL_HOST}:8080 fail_timeout=0;
      }
      server {
          listen 8083;
          server_name localhost;
          charset utf-8;
          # Disables server version feedback on pages and in headers
          server_tokens off;
          proxy_ssl_server_name on;
          location @proxy_to_meet_backend {
              proxy_set_header Host $http_host;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
              proxy_pass http://meet_backend;
          }
          location @proxy_to_meet_frontend {
              proxy_set_header Host $http_host;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

              proxy_redirect off;
              proxy_pass http://meet_frontend;
          }
          location / {
              try_files $uri @proxy_to_meet_frontend;
          }
          location /api {
              try_files $uri @proxy_to_meet_backend;
          }
          location /admin {
              try_files $uri @proxy_to_meet_backend;
          }
          location /static {
              try_files $uri @proxy_to_meet_backend;
          }
      }
    '';
  };
in {
  virtualisation.oci-containers.containers = {
    "meet-backend" = {
      environment = sharedEnv;
      image = "lasuite/meet-backend:latest";
      user = "root:root";
      dependsOn = [
        "postres"
        "valkey"
      ];
    };

    "meet-frontend" = {
      cmd = [
        "nginx"
        "-g"
        "daemon off;"
      ];
      entrypoint = "/docker-entrypoint.sh";
      environment = sharedEnv;
      image = "lasuite/meet-frontend:latest";
      ports = ["127.0.0.1:8083:8083"];
      user = "root:root";
      volumes = ["${defaultConfTemplate}:/etc/nginx/conf.d/docs.conf:ro"];
    };
  };

  systemd.services.meet-backend-migrate = {
    description = "meet-backend-migrate";
    wantedBy = ["multi-user.target"];
    path = with pkgs; [zfs];
    after = [
      "podman-postgres.service"
      "create-pg-db-for-meet.service"
      "podman-meet-backend.service"
    ];
    requires = [
      "podman-postgres.service"
      "create-pg-db-for-meet.service"
      "podman-meet-backend.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.podman}/bin/podman exec meet-backend \
        python manage.py migrate --noinput
        ${pkgs.podman}/bin/podman exec meet-backend \
          python manage.py createsuperuser --email ${DJANGO_SUPERUSER_EMAIL} --password ${DJANGO_SUPERUSER_PASSWORD} || true
    '';
  };

  systemd.services.create-pg-db-for-meet = {
    wantedBy = ["multi-user.target"];
    after = ["podman-postgres.service"];
    description = "Initialize PostgreSQL users and databases for meet";
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = let
        psql = "${pkgs.podman}/bin/podman exec -i postgres psql -U postgres";
      in
        pkgs.writeShellScript "create-pg-db-for-meet" ''
          if ${psql} -tAc "SELECT 1 FROM pg_database WHERE datname='meet'" | grep -q 1; then
            echo "Database 'meet' already exists, skipping initialization."
            exit 0
          fi

          echo "Creating role and database for meet..."
          ${psql} \
            -c "CREATE ROLE meet WITH LOGIN PASSWORD '${DB_PASSWORD}';" \
            -c "CREATE DATABASE meet WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=meet;"
        '';
    };
  };
}
