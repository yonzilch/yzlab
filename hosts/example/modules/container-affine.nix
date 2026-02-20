{
  lib,
  pkgs,
  ...
}: {
  # ── AFFiNE Migration (oneshot) ───────────────────────────────
  virtualisation.oci-containers.containers."affine-migration" = {
    image = "ghcr.io/toeverything/affine:stable";
    pull = "newer";
    dependsOn = [
      "pgvector"
      "valkey"
    ];
    cmd = [
      "sh"
      "-c"
      "node ./scripts/self-host-predeploy.js"
    ];
    environment = {
      REDIS_SERVER_HOST = "valkey";
      REDIS_SERVER_PORT = "6379";
      DATABASE_URL = "postgresql://affine:xxxxxx@pgvector:5432/affine";
      AFFINE_INDEXER_ENABLED = "true";
      AFFINE_INDEXER_SEARCH_ENDPOINT = "http://manticore:9308";
    };
    volumes = [
      "affine_storage:/root/.affine/storage"
      "affine_config:/root/.affine/config"
    ];
    extraOptions = ["--restart=no"]; # migration runs only once
  };

  # ── AFFiNE Server ─────────────────────────────────────────────
  virtualisation.oci-containers.containers."affine" = {
    image = "ghcr.io/toeverything/affine:stable";
    pull = "newer";
    dependsOn = [
      "pgvector"
      "valkey"
    ];
    environment = {
      REDIS_SERVER_HOST = "valkey";
      REDIS_SERVER_PORT = "6379";
      DATABASE_URL = "postgresql://affine:xxxxxx@pgvector:5432/affine";
      AFFINE_INDEXER_ENABLED = "true";
      AFFINE_INDEXER_SEARCH_ENDPOINT = "http://manticore:9308";

      AFFINE_SERVER_HOST = "affine.example.com";
      AFFINE_SERVER_HTTPS = "true";
      # Alternative: AFFINE_SERVER_EXTERNAL_URL = "https://affine.example.com";

      # Optional: External LLM provider
      # OPENAI_BASE_URL = "";
      # OPENAI_API_KEY = "xxxxxx";

      NODE_OPTIONS = "--max-old-space-size=4096";
    };
    volumes = [
      "affine_storage:/root/.affine/storage"
      "affine_config:/root/.affine/config"
    ];
    ports = [
      "127.0.0.1:3010:3010"
    ];
  };

  # ── Override migration container restart policy ───────────────
  systemd.services.podman-affine-migration = {
    serviceConfig = {
      Restart = lib.mkForce "no";
    };
  };

  # ── Database Initialization ───────────────────────────────────
  systemd.services.create-pg-db-for-affine = {
    wantedBy = ["multi-user.target"];
    after = ["podman-pgvector.service"];
    description = "Initialize PostgreSQL user and database for affine";
    # Required when using ZFS-backed storage
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i pgvector \
        psql -U postgres \
        -c "CREATE ROLE affine WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE affine WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=affine;"
      '';
    };
  };
}
