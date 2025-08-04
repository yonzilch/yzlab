_: {
  environment.etc."nginx/self-sign.crt" = {
    mode = "0755";
    text = ''
      -----BEGIN CERTIFICATE-----
      MIIBhDCCASmgAwIBAgIUCIynWdDFXaRIADI0VJ0cTUm6J08wCgYIKoZIzj0EAwIw
      FjEUMBIGA1UEAwwLZXhhbXBsZS5jb20wIBcNMjUwMzIxMDIzNDQ4WhgPMjEyNTAy
      MjUwMjM0NDhaMBYxFDASBgNVBAMMC2V4YW1wbGUuY29tMFkwEwYHKoZIzj0CAQYI
      KoZIzj0DAQcDQgAE9Y1Vju3Fbn/rwDLegFyCqj/xjmZJGWVpz4JjQla8i+luoUqc
      Fl6QFKufFJKSVwueYFY4kaOYuMxfbE6eXmQt/aNTMFEwHQYDVR0OBBYEFHfwESCT
      5AuBnApyfs6B6+ggDsUrMB8GA1UdIwQYMBaAFHfwESCT5AuBnApyfs6B6+ggDsUr
      MA8GA1UdEwEB/wQFMAMBAf8wCgYIKoZIzj0EAwIDSQAwRgIhAOT5/0CvFfak2PHp
      AUK3P6cxVvGHGZQ/bTeKkEiIf2M2AiEAv1eK55VXxFkrJktNWjc9BxP633RYglL7
      2YIjX8XfPPU=
      -----END CERTIFICATE-----
    '';
  };
  environment.etc."nginx/self-sign.key" = {
    mode = "0755";
    text = ''
      -----BEGIN PRIVATE KEY-----
      MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgbv/0QOAaGGilO2Ak
      FJqiXpR0XqVFT2iDydNOCcg5gGyhRANCAAT1jVWO7cVuf+vAMt6AXIKqP/GOZkkZ
      ZWnPgmNCVryL6W6hSpwWXpAUq58UkpJXC55gVjiRo5i4zF9sTp5eZC39
      -----END PRIVATE KEY-----
    '';
  };
  environment.etc."nginx/basicAuthFile" = {
    mode = "0755";
    text = ''
      yzlab:$2y$05$xaYSQxPhFTegvXmyI0tyK..7Dy2.KgqInkavMPUuPBgWHNFI/9CQG
    '';
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
      "share.yzlab.eu.org" = {
        forceSSL = true;
        kTLS = true;
        sslCertificate = "/etc/nginx/self-sign.crt";
        sslCertificateKey = "/etc/nginx/self-sign.key";
        locations."/" = {
          proxyPass = "http://127.0.0.1:5244";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header Accept-Encoding "";
            sub_filter 'g.alicdn.com' 'localhost';
            sub_filter 'jsd.nn.ci' 'localhost';
            sub_filter_once off;
            sub_filter_types *;
          '';
        };
      };
      "st-silicon.yzlab.qzz.io" = {
        forceSSL = true;
        kTLS = true;
        sslCertificate = "/etc/nginx/self-sign.crt";
        sslCertificateKey = "/etc/nginx/self-sign.key";
        locations."/" = {
          proxyPass = "http://127.0.0.1:8384";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header Accept-Encoding "";
          '';
        };
      };
    };
  };
}
