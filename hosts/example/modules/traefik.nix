{config, ...}: {
  environment.etc."traefik-environment" = {
    mode = "0755";
    text = ''
      CF_API_EMAIL=xxxxxx
      CF_ZONE_API_TOKEN=xxxxxx
      CLOUDFLARE_DNS_API_TOKEN=xxxxxx
    '';
  };

  services.traefik = {
    enable = true;
    environmentFiles = [/etc/traefik-environment];
    staticConfigOptions = {
      # Disable the Traefik dashboard
      api.dashboard = false;
      api.insecure = false;
      # log = {
      # level = "INFO";
      # filePath = "${config.services.traefik.dataDir}/traefik.log";
      # format = "json";
      # };
      entryPoints = {
        # web = {
        #   address = ":80";
        # };
        websecure = {
          address = ":443";
          http.tls = {
            certResolver = "myresolver";
            domains = {
              main = "example.com";
              sans = ["*.example.com"];
            };
          };
        };
      };

      certificatesResolvers.myresolver.acme = {
        dnsChallenge = {
          provider = "cloudflare";
          delayBeforeCheck = "10";
        };
        email = "no-reply@example.com";
        storage = "${config.services.traefik.dataDir}/acme.json";
        # httpChallenge.entryPoint = "web";
      };
    };

    dynamicConfigOptions = {
      http = {
        middlewares.auth.basicauth.users = "foobar:xxxxxx";
        routers = {
          jellyfin = {
            entryPoints = ["websecure"];
            rule = "Host(`jellyfin.example.com`)";
            service = "jellyfin";
            tls.certresolver = "myresolver";
            # middlewares = "auth";
          };
        };
        services = {
          jellyfin = {
            loadBalancer = {
              servers = [
                {
                  url = "http://localhost:8096";
                }
              ];
            };
          };
        };
      };
    };
  };
}
