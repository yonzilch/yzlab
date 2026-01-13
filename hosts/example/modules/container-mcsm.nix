{pkgs, ...}: {
  virtualisation.oci-containers.containers."mcsmanager-daemon" = {
    image = "ngc7331/mcsmanager-daemon:latest-nojdk";
    environment = {
      "MCSM_DOCKER_WORKSPACE_PATH" = "/var/lib/containers/storage/volumes/mcsmanager-daemon_data/_data/InstanceData";
      "JAVA_HOME" = "/opt/java/java-8";
      "PATH" = "/opt/java/java-8/bin:/opt/java/java-21/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
    };
    volumes = [
      "mcsmanager-daemon_data:/opt/mcsm/daemon/data:rw"
      "mcsmanager-daemon_logs:/opt/mcsm/daemon/logs:rw"
      "mcsmanager-daemon_java:/opt/java:rw"
      "/run/podman/podman.sock:/var/run/docker.sock:rw"
    ];
    ports = [
      "127.0.0.1:24444:24444/tcp"
      "25565:25565"
    ];
  };

  virtualisation.oci-containers.containers."mcsmanager-web" = {
    image = "ngc7331/mcsmanager-web:latest";
    volumes = [
      "mcsmanager-web_data:/opt/mcsm/web/data:rw"
      "mcsmanager-web_logs:/opt/mcsm/web/logs:rw"
    ];
    ports = [
      "127.0.0.1:23333:23333/tcp"
    ];
  };

  systemd.services.install-jdk-for-mcsmanager-daemon = {
    wantedBy = ["multi-user.target"];
    after = ["podman-mcsmanager-daemon.service"];
    description = "Install JDK for mcsmanager-daemon";
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "install-jdk.sh" ''
        sleep 5

        if ! ${pkgs.podman}/bin/podman exec mcsmanager-daemon test -f /opt/java/.installed 2>/dev/null; then
          echo "Installing Java packages..."
          ${pkgs.podman}/bin/podman exec mcsmanager-daemon sh -c "
            apk update && apk add openjdk8 openjdk21 && \
            mkdir -p /opt/java && \
            cp -r /usr/lib/jvm/java-1.8-openjdk /opt/java/java-8 && \
            cp -r /usr/lib/jvm/java-21-openjdk /opt/java/java-21 && \
            touch /opt/java/.installed
          "
          echo "Java installed to persistent volume"
        fi
      '';
    };
  };
}
