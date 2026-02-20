{pkgs, ...}: {
  virtualisation.oci-containers.containers."photoview" = {
    image = "photoview/photoview:latest";
    pull = "newer";
    dependsOn = [
      "postgres"
    ];
    environment = {
      # ── Database ────────────────────────────────────────────────────
      PHOTOVIEW_DATABASE_DRIVER = "postgres";
      PHOTOVIEW_POSTGRES_URL = "postgres://photoview:xxxxxx@postgres:5432/photoview?sslmode=disable";

      # ── Server listening ────────────────────────────────────────────
      PHOTOVIEW_LISTEN_IP = "0.0.0.0";
      PHOTOVIEW_LISTEN_PORT = "39013";

      # ── Cache ───────────────────────────────────────────────────────
      PHOTOVIEW_MEDIA_CACHE = "/home/photoview/media-cache";

      # ── Optional: Mapbox token for maps ─────────────────────────────
      # MAPBOX_TOKEN = "xxxxxx";

      # ── Optional: Hardware acceleration for video thumbnails ────────
      # PHOTOVIEW_VIDEO_HARDWARE_ACCELERATION = "qsv";
    };

    volumes = [
      "photoview_media-cache:/home/photoview/media-cache"
      "photoview_photos:/photos:ro"
    ];

    ports = [
      "127.0.0.1:39013:39013"
    ];

    extraOptions = [
      "--security-opt=seccomp=unconfined"
      "--security-opt=apparmor=unconfined"
    ];
  };

  systemd.services.create-pg-db-for-photoview = {
    wantedBy = ["multi-user.target"];
    after = ["podman-postgres.service"];
    description = "Initialize PostgreSQL user and database for photoview";
    # Required when using ZFS-backed storage (otherwise podman complains about missing zfs command)
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i postgres \
        psql -U postgres \
        -c "CREATE ROLE photoview WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE photoview WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=photoview;"
      '';
    };
  };
}
