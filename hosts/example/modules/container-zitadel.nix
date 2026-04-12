{pkgs, ...}: {
  # zitadel-api
  virtualisation.oci-containers.containers."zitadel-api" = {
    image = "ghcr.io/zitadel/zitadel:latest";
    cmd = [
      "start-from-init"
      "--masterkey"
      "xxxxxx"
    ];
    environment = {
      "ZITADEL_PORT" = "8080";
      "ZITADEL_EXTERNALDOMAIN" = "sso.example.com";
      "ZITADEL_EXTERNALPORT" = "443";
      "ZITADEL_EXTERNALSECURE" = "true";
      "ZITADEL_TLS_ENABLED" = "false";

      "ZITADEL_DATABASE_POSTGRES_HOST" = "postgres";
      "ZITADEL_DATABASE_POSTGRES_PORT" = "5432";
      "ZITADEL_DATABASE_POSTGRES_DATABASE" = "zitadel";
      "ZITADEL_DATABASE_POSTGRES_USER_USERNAME" = "zitadel";
      "ZITADEL_DATABASE_POSTGRES_USER_PASSWORD" = "xxxxxx";
      "ZITADEL_DATABASE_POSTGRES_USER_SSL_MODE" = "disable";
      "ZITADEL_DATABASE_POSTGRES_ADMIN_USERNAME" = "postgres";
      "ZITADEL_DATABASE_POSTGRES_ADMIN_PASSWORD" = "xxxxxx";
      "ZITADEL_DATABASE_POSTGRES_ADMIN_SSL_MODE" = "disable";

      "ZITADEL_FIRSTINSTANCE_ORG_HUMAN_PASSWORDCHANGEREQUIRED" = "false";
      "ZITADEL_FIRSTINSTANCE_LOGINCLIENTPATPATH" = "/zitadel/bootstrap/login-client.pat";
      "ZITADEL_FIRSTINSTANCE_ORG_LOGINCLIENT_MACHINE_USERNAME" = "login-client";
      "ZITADEL_FIRSTINSTANCE_ORG_LOGINCLIENT_MACHINE_NAME" = "Automatically Initialized IAM_LOGIN_CLIENT";
      "ZITADEL_FIRSTINSTANCE_ORG_LOGINCLIENT_PAT_EXPIRATIONDATE" = "2077-01-01T00:00:00Z";

      "ZITADEL_DEFAULTINSTANCE_FEATURES_LOGINV2_REQUIRED" = "true";
      "ZITADEL_DEFAULTINSTANCE_FEATURES_LOGINV2_BASEURI" = "https://sso.example.com/ui/v2/login/";
      "ZITADEL_OIDC_DEFAULTLOGINURLV2" = "https://sso.example.com/ui/v2/login/login?authRequest=";
      "ZITADEL_OIDC_DEFAULTLOGOUTURLV2" = "https://sso.example.com/ui/v2/login/logout?post_logout_redirect=";
      "ZITADEL_SAML_DEFAULTLOGINURLV2" = "https://sso.example.com/ui/v2/login/login?samlRequest=";
    };
    volumes = [
      "zitadel_bootstrap:/zitadel/bootstrap"
    ];
    ports = [
      "127.0.0.1:48291:8080"
    ];
    extraOptions = [
      "--user=0"
    ];
  };

  # zitadel-login
  virtualisation.oci-containers.containers."zitadel-login" = {
    image = "ghcr.io/zitadel/zitadel-login:latest";
    environment = {
      "ZITADEL_API_URL" = "http://zitadel-api:8080";
      "NEXT_PUBLIC_BASE_PATH" = "/ui/v2/login";
      "ZITADEL_SERVICE_USER_TOKEN_FILE" = "/zitadel/bootstrap/login-client.pat";
      "CUSTOM_REQUEST_HEADERS" = "Host:sso.example.com,X-Forwarded-Proto:https";
    };
    volumes = [
      "zitadel_bootstrap:/zitadel/bootstrap"
    ];
    ports = [
      "127.0.0.1:48292:3000"
    ];
    extraOptions = [
      "--user=0"
    ];
    dependsOn = ["zitadel-api"];
  };

  systemd.services.create-pg-db-for-zitadel = {
    wantedBy = ["multi-user.target"];
    after = ["podman-postgres.service"];
    description = "Initialize PostgreSQL users and databases for zitadel";
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i postgres \
        psql -U postgres \
        -c "CREATE ROLE zitadel WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE zitadel WITH LOCALE='C.UTF-8' TEMPLATE=template0 OWNER=zitadel;"
      '';
    };
  };
}
