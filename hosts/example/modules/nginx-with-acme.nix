{
  lib,
  pkgs,
  ...
}: {
  environment.etc."acme/credentialsFile" = {
    mode = "0644";
    text = ''
      CLOUDFLARE_DNS_API_TOKEN=
      CLOUDFLARE_ZONE_API_TOKEN=
    '';
  };

  environment.etc."nginx/self-sign.crt" = {
    mode = "0755";
    text = ''
      -----BEGIN CERTIFICATE-----
      MIIDITCCAsegAwIBAgIQALLUnmUFqCrEw9UVprMuVzAKBggqhkjOPQQDAjCBrDEU
      MBIGA1UEAwwLZXhhbXBsZS5jb20xDDAKBgNVBAoMA1NBVjEMMAoGA1UECwwDU0FW
      MQwwCgYDVQQGEwNVU0ExEzARBgNVBAgMCkNhbGlmb3JuaWExFDASBgNVBAcMC0xv
      cyBBbmdlbGVzMSMwIQYDVQQJDBpXaWxzaGlyZSBCbHZkLCBMb3MgQW5nZWxlczEa
      MBgGCSqGSIb3DQEJARYLZm9vQGJhci5jb20wHhcNMjUwNzIzMTQyNDAzWhcNMzUw
      NzIxMTQyNDAzWjCBrDEUMBIGA1UEAwwLZXhhbXBsZS5jb20xDDAKBgNVBAoMA1NB
      VjEMMAoGA1UECwwDU0FWMQwwCgYDVQQGEwNVU0ExEzARBgNVBAgMCkNhbGlmb3Ju
      aWExFDASBgNVBAcMC0xvcyBBbmdlbGVzMSMwIQYDVQQJDBpXaWxzaGlyZSBCbHZk
      LCBMb3MgQW5nZWxlczEaMBgGCSqGSIb3DQEJARYLZm9vQGJhci5jb20wWTATBgcq
      hkjOPQIBBggqhkjOPQMBBwNCAAT+ojQoP8bVzxvagQXTcjgu+Uva3VLgUxi6ZVxJ
      VfgVsHEAtkxyo1HoAnHlOjHGpIuRMQZaGIW9q9hUf6Z7BemLo4HIMIHFMCUGA1Ud
      EQQeMByCDSouZXhhbXBsZS5jb22CC2V4YW1wbGUuY29tMB0GA1UdDgQWBBS2JqHo
      aVYRZF2i/LoJdtnvXfD5pTAOBgNVHQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB
      /zA7BgNVHSUENDAyBggrBgEFBQcDAgYIKwYBBQUHAwEGCCsGAQUFBwMDBggrBgEF
      BQcDBAYIKwYBBQUHAwgwHwYDVR0jBBgwFoAUtiah6GlWEWRdovy6CXbZ713w+aUw
      CgYIKoZIzj0EAwIDSAAwRQIgdUz1DVK9HsmbtqWMnR/sffKSk6a7fdDic1NWR/WK
      SWECIQDMI3KycaDQMcaRxv8WH7N9jJa2I9I62nnoUf41f9paVA==
      -----END CERTIFICATE-----
    '';
  };
  environment.etc."nginx/self-sign.key" = {
    mode = "0755";
    text = ''
      -----BEGIN PRIVATE KEY-----
      MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgOZU83QpMl0sDYUNq
      mRIWwat4V91rUZVVh2/6mPgUXcugCgYIKoZIzj0DAQehRANCAAT+ojQoP8bVzxva
      gQXTcjgu+Uva3VLgUxi6ZVxJVfgVsHEAtkxyo1HoAnHlOjHGpIuRMQZaGIW9q9hU
      f6Z7BemL
      -----END PRIVATE KEY-----
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      credentialsFile = "/etc/acme/credentialsFile";
      dnsProvider = "cloudflare";
      email = "no-reply@example.com";
    };
    certs."wildcard-example-com" = {
      domain = "*.example.com";
    };
  };

  services.nginx = {
    user = "www";
    group = "www";
    package = pkgs.nginx.override {
      modules = with pkgs.nginxModules; [moreheaders];
    };
    appendConfig = ''
      worker_processes auto;
      worker_rlimit_nofile 65535;
    '';
    appendHttpConfig = ''
      more_clear_headers Server;
    '';
    clientMaxBodySize = "10240m";
    enable = true;
    enableReload = true;
    eventsConfig = ''
      use epoll;
      worker_connections 65535;
      multi_accept on;
    '';
    proxyTimeout = "600s";
    recommendedOptimisation = true;
    serverTokens = false;
    virtualHosts = {
      "_" = {
        forceSSL = true;
        http3 = true;
        kTLS = true;
        quic = true;
        locations."/" = {
          extraConfig = ''
            return 403;
          '';
        };
        sslCertificate = "/etc/nginx/self-sign.crt";
        sslCertificateKey = "/etc/nginx/self-sign.key";
      };
      "static.example.com" = {
        forceSSL = true;
        http3 = true;
        kTLS = true;
        quic = true;
        useACMEHost = "wildcard-example-com";
        root = "/home/www/sync/static-yon-im";
        extraConfig = ''
          sendfile on;
          tcp_nopush on;

          location ~* \.(avif|webp|jpg|jpeg|png|gif|svg|ico|mp4|woff2)$ {
            expires 365d;
            add_header Cache-Control "public, immutable";
            add_header Vary Accept;
          }
        '';
      };

      "app.example.com" = {
        forceSSL = true;
        http3 = true;
        kTLS = true;
        quic = true;
        useACMEHost = "wildcard-example-com";
        locations."/" = {
          proxyPass = "http://127.0.0.1:1234";
          proxyWebsockets = true;
          recommendedProxySettings = true;
          extraConfig = ''
            proxy_buffering off;
          '';
        };
      };
    };
  };

  systemd.services.nginx.serviceConfig = {
    ProtectHome = lib.mkForce false;
  };

  users.users.www.extraGroups = [
    "acme"
  ];
}
