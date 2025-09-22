{pkgs, ...}: {
  environment.etc."caddy/self-sign.crt" = {
    mode = "0755";
    text = ''
      -----BEGIN CERTIFICATE-----
      MIIByTCCAW+gAwIBAgIQAKHhgXo/+CdwFplGoE8GHTAKBggqhkjOPQQDAjAWMRQw
      EgYDVQQDDAtleGFtcGxlLmNvbTAeFw0yNTA5MjEwNzE4NTdaFw0zNTA5MTkwNzE4
      NTdaMBYxFDASBgNVBAMMC2V4YW1wbGUuY29tMFkwEwYHKoZIzj0CAQYIKoZIzj0D
      AQcDQgAEPXkr7caFwq7x0BjsletPTxVwivnUkfMml7EgcVtfaf6CayPIdF+SfkQF
      sSXKeQjT6ynzTIwrHqYbJivA2TBgmqOBnjCBmzAdBgNVHQ4EFgQURMlwLfm7p+Yw
      qPY8hcuqAk6l2AAwDgYDVR0PAQH/BAQDAgSwMAwGA1UdEwEB/wQCMAAwOwYDVR0l
      BDQwMgYIKwYBBQUHAwIGCCsGAQUFBwMBBggrBgEFBQcDAwYIKwYBBQUHAwQGCCsG
      AQUFBwMIMB8GA1UdIwQYMBaAFETJcC35u6fmMKj2PIXLqgJOpdgAMAoGCCqGSM49
      BAMCA0gAMEUCIQCRPGjvHVa7v5BKenKVUVttq7dZytS52coH/s8pRJ6+RwIgBeWR
      kG2jz7k9IjF1E3zOUWLfPWV/E5krjM1ieqpXFAU=
      -----END CERTIFICATE-----
    '';
  };
  environment.etc."caddy/self-sign.key" = {
    mode = "0755";
    text = ''
      -----BEGIN PRIVATE KEY-----
      MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQguN4Zzhyet8yZJi3S
      7XhZtTDnR609q4PISJQuZtJ0l/agCgYIKoZIzj0DAQehRANCAAQ9eSvtxoXCrvHQ
      GOyV609PFXCK+dSR8yaXsSBxW19p/oJrI8h0X5J+RAWxJcp5CNPrKfNMjCsephsm
      K8DZMGCa
      -----END PRIVATE KEY-----
    '';
  };

  services.caddy = {
    enable = true;
    configFile = pkgs.writeText "Caddyfile" ''
      {
        auto_https disable_certs
        servers {
         max_header_size 10240MB
         }
      }
      jellyfin.example.com {
        encode zstd
        tls /etc/caddy/self-sign.crt /etc/caddy/self-sign.key
        reverse_proxy 127.0.0.1:8096
      }
    '';
  };
}
