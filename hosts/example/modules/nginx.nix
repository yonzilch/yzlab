_: {
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
  environment.etc."nginx/basicAuthFile" = {
    mode = "0755";
    text = ''
      foobar:xxxxxx
    '';
    # use this command to generate
    # nix-shell --packages apacheHttpd --run 'htpasswd -B -c FILENAME USERNAME'
  };

  services.nginx = {
    appendConfig = ''
      worker_rlimit_nofile 65535;
    '';
    appendHttpConfig = ''
      access_log off;
      ssl_session_cache shared:SSL:10m;
      ssl_session_timeout 10m;

      # THEME.PARK
      # see https://github.com/themepark-dev/theme.park
      map $host $theme {
          default catppuccin-mocha;
      }
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
        locations."/" = {
          extraConfig = ''
            return 403;
          '';
        };
        sslCertificate = "/etc/nginx/self-sign.crt";
        sslCertificateKey = "/etc/nginx/self-sign.key";
      };
      "jellyfin.example.com" = {
        forceSSL = true;
        kTLS = true;
        sslCertificate = "/etc/nginx/self-sign.crt";
        sslCertificateKey = "/etc/nginx/self-sign.key";
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header Accept-Encoding "";
            set $app jellyfin;
            sub_filter
            '</head>'
            '<link rel="stylesheet" type="text/css" href="https://theme-park.dev/css/base/$app/$theme.css">
            </head>';
            sub_filter_once on;
          '';
        };
      };
    };
  };
}
