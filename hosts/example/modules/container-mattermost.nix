{pkgs, ...}: {
  virtualisation.oci-containers.containers."mattermost" = {
    image = "mattermost/mattermost-team-edition:latest";
    pull = "newer";
    dependsOn = ["postgres"];
    environment = {
      # Database
      "MM_SQLSETTINGS_DRIVERNAME" = "postgres";
      "MM_SQLSETTINGS_DATASOURCE" = "postgres://mattermost:CHANGE_ME_MATTERMOST_DB_PASS@postgres/mattermost?sslmode=disable&connect_timeout=10";

      "MM_SERVICESETTINGS_SITEURL" = "https://chat.example.com";

      "MM_FILESETTINGS_DRIVERNAME" = "local";
      "MM_FILESETTINGS_DIRECTORY" = "/mattermost/data/";

      "MM_LOGSETTINGS_ENABLECONSOLE" = "true";
      "MM_LOGSETTINGS_CONSOLELEVEL" = "INFO";
    };
    volumes = [
      "mattermost_data:/mattermost/data"
      "mattermost_logs:/mattermost/logs"
      "mattermost_config:/mattermost/config"
      "mattermost_plugins:/mattermost/plugins"
      "mattermost_client-plugins:/mattermost/client/plugins"
    ];
    ports = [
      "127.0.0.1:8065:8065/tcp"
    ];
  };

  systemd.services.create-pg-db-for-mattermost = {
    wantedBy = ["multi-user.target"];
    after = ["podman-postgres.service"];
    description = "Initialize PostgreSQL users and databases for Mattermost";
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i postgres \
        psql -U postgres \
        -c "CREATE ROLE mattermost WITH LOGIN PASSWORD 'CHANGE_ME_MATTERMOST_DB_PASS';" \
        -c "CREATE DATABASE mattermost WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=mattermost;"
      '';
    };
  };
}
