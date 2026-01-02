{ pkgs, ... }:
{
  environment.etc = {
    "etherpad/settings.json" = {
      mode = "0755";
      text = ''
        # see https://github.com/ether/etherpad-lite/blob/develop/settings.json.template
      '';
    };
  };

  virtualisation.oci-containers.containers."etherpad" = {
    image = "etherpad/etherpad:latest";
    environment = {
      "NODE_ENV" = "production";
    };
    volumes = [
      "/etc/etherpad/settings.json:/opt/etherpad-lite/settings.json:ro"
      "etherpad-var:/opt/etherpad-lite/var"
      "etherpad-plugins:/opt/etherpad-lite/src/plugin_packages"
    ];
    ports = [
      "127.0.0.1:9001:9001"
    ];
  };

  systemd.services.create-pg-db-for-etherpad = {
    wantedBy = [ "multi-user.target" ];
    after = [ "podman-postgres.service" ];
    # requires = ["podman-postgres.service"];
    description = "Initialize PostgreSQL users and databases";
    # Without this line, it would Error: configure storage:
    # the 'zfs' command is not available:
    # prerequisites for driver not satisfied (wrong filesystem?)
    path = with pkgs; [ zfs ];
    serviceConfig = {
      Type = "oneshot";
      SuccessExitStatus = "0 1";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i postgres \
        psql -U postgres \
        -c "CREATE ROLE etherpad WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE etherpad WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=etherpad;"
      '';
    };
  };
}
