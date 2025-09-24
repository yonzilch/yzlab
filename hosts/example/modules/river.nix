{pkgs, ...}: {
  services.river = {
    enable = true;
    # see https://github.com/memorysafety/river
    configFile = "${pkgs.writeText "config.kdl" ''
      services {
          Example1 {
              listeners {
                  "0.0.0.0:8080"
              }
              connectors {
                  "91.107.223.4:80" tls-sni="onevariable.com" proto="h2-or-h1"
              }
          }
      }
    ''}";
  };
}
