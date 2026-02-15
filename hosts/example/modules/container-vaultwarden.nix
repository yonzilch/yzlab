_: {
  virtualisation.oci-containers.containers."vaultwarden" = {
    image = "ghcr.io/dani-garcia/vaultwarden:latest";
    pull = "newer";
    environment = {
      "ADMIN_TOKEN" = ""; # see https://github.com/dani-garcia/vaultwarden/wiki/Enabling-admin-page#secure-the-admin_token
      "DOMAIN" = "https://vaultwarden.example.com";
      "LOG_LEVEL" = "warn";
      "ROCKET_ADDRESS" = "0.0.0.0";
      "ROCKET_PORT" = "80";
      "ROCKET_PROFILE" = "release";
      "SHOW_PASSWORD_HINT" = "false";
      "SIGNUPS_ALLOWED" = "false";
      "INVITATIONS_ALLOWED" = "true";
      "SMTP_HOST" = "";
      "SMTP_PORT" = "465";
      "SMTP_SECURITY" = "force_tls";
      "SMTP_FROM" = "";
      "SMTP_USERNAME" = "";
      "SMTP_PASSWORD" = "";
      "SSO_ENABLED" = "true";
      "SSO_ONLY" = "true";
      "SSO_ALLOW_UNKNOWN_EMAIL_VERIFICATION" = "true";
      "SSO_AUTHORITY" = "";
      "SSO_CLIENT_ID" = "";
      "SSO_CLIENT_SECRET" = "";
    };
    volumes = [
      "vaultwarden:/data:rw"
    ];
    ports = [
      "127.0.0.1:37129:80/tcp"
    ];
  };
}
