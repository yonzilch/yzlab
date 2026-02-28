{pkgs, ...}: {
  environment.etc."misskey/default.yml" = {
    text = ''
      url: https://misskey.example.com
      port: 3000

      db:
        host: pgroonga
        port: 5432
        db: misskey
        user: misskey
        pass: xxxxxx

      redis:
        host: valkey
        port: 6379

      fulltextSearch:
        provider: sqlPgroonga

      # meilisearch:
      #   host: meilisearch
      #   port: 7700
      #   apiKey: xxxxxx
      #   index: misskey
      #   scope: local   # local or global (whether to index federated instances)

      # ID generation method
      id: 'aidx'

      # Media storage configuration
      drive:
        storage: 'fs'
        # storage: 's3'
        # bucket: 'misskey-media'
        # prefix: 'files'
        # endpoint: 'https://your-bucket.r2.cloudflarestorage.com'
        # region: 'auto'
        # accessKey: ' '
        # secretKey: ' '

      # Proxy bypass list (useful when behind Cloudflare / reverse proxy)
      proxyBypassHosts:
        - api.deepl.com
        - api-free.deepl.com
        - www.recaptcha.net
        - hcaptcha.com
        - challenges.cloudflare.com

      # Queue / delivery performance tuning
      deliverJobConcurrency: 128
      inboxJobConcurrency: 16
      deliverJobPerSec: 128
      inboxJobPerSec: 32
      deliverJobMaxAttempts: 12
      inboxJobMaxAttempts: 8

      # Media processing
      # mediaProxy: https://example.com/proxy
      maxFileSize: 104857600   # 100 MiB

      # ActivityPub signature (helps prevent SSRF in some cases)
      signToActivityPubGet: true

      # CORS / private network access
      allowedPrivateNetworks: []
    '';
    mode = "0755";
  };

  virtualisation.oci-containers.containers."misskey" = {
    pull = "newer";
    image = "misskey/misskey:latest";

    dependsOn = [
      "pgroonga"
      "valkey"
    ];

    volumes = [
      "misskey:/misskey/files:rw"
      "/etc/misskey/default.yml:/misskey/.config/default.yml"
      "/etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt"
    ];

    ports = [
      "127.0.0.1:3000:3000"
    ];

    environment = {
      NODE_ENV = "production";
    };

    extraOptions = [
      "--health-cmd=curl -f http://localhost:3000/ || exit 1"
      "--health-interval=30s"
      "--health-timeout=10s"
      "--health-retries=5"
      "--health-start-period=60s"
    ];
  };

  systemd.services.create-pg-db-for-misskey = {
    wantedBy = ["multi-user.target"];
    after = ["podman-pgroonga.service"];
    description = "Initialize PostgreSQL user and database for misskey";
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i pgroonga \
        psql -U postgres \
        -c "CREATE ROLE misskey WITH LOGIN PASSWORD 'xxxxxx';" \
        -c "CREATE DATABASE misskey WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0 OWNER=misskey;"
      '';
    };
  };
}
