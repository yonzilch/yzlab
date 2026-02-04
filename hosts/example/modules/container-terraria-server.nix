{
  config,
  ...
}:
{
  # use command
  # podman run --rm -it -p 7777:7777 -v terraria-server_config:/config --name=terraria ghcr.io/beardedio/terraria:vanilla-1.4.5.3
  # to mannually generate a world

  virtualisation.oci-containers.containers."terraria-server" = {
    image = "ghcr.io/beardedio/terraria:vanilla-1.4.5.3";
    environment = {
      world = "example.wld";
    };
    volumes = [
      "terraria-server_config:/config:rw"
    ];
    ports = [
      "7777:7777"
    ];
  };
  systemd.tmpfiles.rules = [
    "d ${config.virtualisation.containers.storage.settings.storage.graphroot}/volumes/terraria-server_config/_data root root"
  ];
}
