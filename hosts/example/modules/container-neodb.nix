{
  pkgs,
  lib,
  ...
}: let
  neodbSecretKey = "xxxxxx";
  siteDomain = "neodb.example.com";

  sharedEnv = {
    # see https://neodb.net/configuration
    NEODB_SECRET_KEY = neodbSecretKey;
    NEODB_SITE_NAME = "NeoDB";
    NEODB_SITE_DOMAIN = siteDomain;
    NEODB_DEBUG = "False";
    TAKAHE_ENVIRONMENT = "production";
    TAKAHE_DEBUG = "False";

    NEODB_DB_URL = "postgres://neodb:xxxxxx@pgroonga/neodb";
    TAKAHE_DB_URL = "postgres://takahe:xxxxxx@pgroonga/takahe";
    TAKAHE_DATABASE_SERVER = "postgres://takahe:xxxxxx@pgroonga/takahe";

    NEODB_REDIS_URL = "redis://valkey:6379/0";
    TAKAHE_CACHES_DEFAULT = "redis://valkey:6379/0";

    NEODB_SEARCH_URL = "typesense://user:xxxxxx@typesense:8108/catalog";

    NEODB_MEDIA_ROOT = "/www/m";
    NEODB_MEDIA_URL = "/m/";
    NEODB_VENV = "/neodb-venv";

    TAKAHE_SECRET_KEY = neodbSecretKey;
    TAKAHE_MAIN_DOMAIN = siteDomain;
    TAKAHE_MEDIA_ROOT = "/www/media";
    TAKAHE_MEDIA_URL = "https://${siteDomain}/media/";
    TAKAHE_MEDIA_BACKEND = "local://";
    TAKAHE_VENV = "/takahe-venv";
    TAKAHE_USE_PROXY_HEADERS = "true";
    TAKAHE_STATOR_CONCURRENCY = "4";
    TAKAHE_STATOR_CONCURRENCY_PER_MODEL = "2";

    # NEODB_EMAIL_URL = "smtp://noreply@example.com:changeme@hostname:587";
    NEODB_EMAIL_FROM = "no-reply@${siteDomain}";
    TAKAHE_EMAIL_FROM = "no-reply@${siteDomain}";

    NEODB_PREFERRED_LANGUAGES = "en,zh";
    NEODB_INVITE_ONLY = "true";
  };

  sharedVolumes = [
    "neodb_neodb-media:/www/m"
    "neodb_takahe-media:/www/media"
    "neodb_takahe-cache:/www/cache"
    "neodb_www-root:/www/root"
  ];

  sharedDeps = [
    "pgroonga"
    "typesense"
    "valkey"
  ];
in {
  # ── Migration（oneshot）────────────────────────────
  virtualisation.oci-containers.containers."neodb-migration" = {
    image = "neodb/neodb:latest";
    pull = "newer";
    dependsOn = sharedDeps;
    cmd = ["/bin/neodb-init"];
    environment = sharedEnv;
    volumes = sharedVolumes;
  };

  # ── NeoDB Web ────────────────────────────────────────────────
  virtualisation.oci-containers.containers."neodb-web" = {
    image = "neodb/neodb:latest";
    pull = "newer";
    dependsOn = sharedDeps;
    cmd = [
      "/neodb-venv/bin/gunicorn"
      "boofilsic.wsgi"
      "-w"
      "8"
      "--preload"
      "--max-requests"
      "2000"
      "--timeout"
      "60"
      "-b"
      "0.0.0.0:8000"
    ];
    environment = sharedEnv;
    volumes = sharedVolumes;
    ports = ["127.0.0.1:8091:8000"];
  };

  # ── NeoDB Web API ────────────────────────────────────────────
  virtualisation.oci-containers.containers."neodb-web-api" = {
    image = "neodb/neodb:latest";
    pull = "newer";
    dependsOn = sharedDeps;
    cmd = [
      "/neodb-venv/bin/gunicorn"
      "boofilsic.wsgi"
      "-w"
      "4"
      "--preload"
      "--max-requests"
      "2000"
      "--timeout"
      "30"
      "-b"
      "0.0.0.0:8000"
    ];
    environment = sharedEnv;
    volumes = sharedVolumes;
    ports = ["127.0.0.1:8092:8000"];
  };

  # ── NeoDB Worker ─────────────────────────────────────────────
  virtualisation.oci-containers.containers."neodb-worker" = {
    image = "neodb/neodb:latest";
    pull = "newer";
    dependsOn = sharedDeps;
    cmd = [
      "neodb-manage"
      "rqworker-pool"
      "--num-workers"
      "4"
      "import"
      "export"
      "mastodon"
      "fetch"
      "crawl"
      "ap"
      "cron"
    ];
    environment = sharedEnv;
    volumes = sharedVolumes;
  };

  # ── NeoDB Worker Extra ───────────────────────────────────────
  virtualisation.oci-containers.containers."neodb-worker-extra" = {
    image = "neodb/neodb:latest";
    pull = "newer";
    dependsOn = sharedDeps;
    cmd = [
      "neodb-manage"
      "rqworker-pool"
      "--num-workers"
      "4"
      "mastodon"
      "fetch"
      "crawl"
      "ap"
    ];
    environment = sharedEnv;
    volumes = sharedVolumes;
  };

  # ── Takahe Web ───────────────────────────────────────────────
  virtualisation.oci-containers.containers."neodb-takahe-web" = {
    image = "neodb/neodb:latest";
    pull = "newer";
    dependsOn = sharedDeps;
    cmd = [
      "/takahe-venv/bin/gunicorn"
      "--chdir"
      "/takahe"
      "takahe.wsgi"
      "-w"
      "8"
      "--max-requests"
      "2000"
      "--timeout"
      "60"
      "--preload"
      "-b"
      "0.0.0.0:8000"
    ];
    environment = sharedEnv;
    volumes = sharedVolumes;
    ports = ["127.0.0.1:8093:8000"];
  };

  # ── Takahe Stator ────────────────────────────────────────────
  virtualisation.oci-containers.containers."neodb-takahe-stator" = {
    image = "neodb/neodb:latest";
    pull = "newer";
    dependsOn = sharedDeps;
    cmd = [
      "takahe-manage"
      "runstator"
    ];
    environment = sharedEnv;
    volumes = sharedVolumes;
  };

  # ── Nginx（ingress）─────────────────────────────────────────
  virtualisation.oci-containers.containers."neodb-nginx" = {
    image = "neodb/neodb:latest";
    pull = "newer";
    user = "root:root";
    dependsOn = [
      "neodb-web"
      "neodb-takahe-web"
    ];
    cmd = ["nginx-start"];
    environment =
      sharedEnv
      // {
        NEODB_WEB_SERVER = "neodb-web:8000";
        NEODB_API_SERVER = "neodb-web-api:8000";
        TAKAHE_WEB_SERVER = "neodb-takahe-web:8000";
        NGINX_CONF = "/neodb/misc/nginx.conf.d/neodb.conf";
      };
    volumes = sharedVolumes;
    ports = ["127.0.0.1:8000:8000"];
  };

  # ── Initial db ─────────────────────────────────────────────
  systemd.services.create-pg-db-for-neodb = {
    wantedBy = ["multi-user.target"];
    after = ["podman-pgroonga.service"];
    description = "Initialize PostgreSQL databases for NeoDB and Takahe";
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = pkgs.writeShellScript "create-pg-db-for-neodb" ''
        ${pkgs.podman}/bin/podman exec -i pgroonga psql -U postgres <<EOF
        CREATE USER neodb WITH PASSWORD 'xxxxxx';
        CREATE DATABASE neodb OWNER neodb;
        CREATE USER takahe WITH PASSWORD 'xxxxxx';
        CREATE DATABASE takahe OWNER takahe;
        EOF
      '';
    };
  };

  # declare migration restart policy
  systemd.services.podman-neodb-migration = {
    serviceConfig = {
      Restart = lib.mkForce "no";
    };
  };
}
