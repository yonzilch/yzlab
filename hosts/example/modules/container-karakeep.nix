_: {
  virtualisation.oci-containers.containers."karakeep" = {
    pull = "newer";
    image = "ghcr.io/karakeep-app/karakeep:release";
    environment = {
      # see https://docs.karakeep.app/configuration/environment-variables
      KARAKEEP_VERSION = "release";
      NEXTAUTH_SECRET = "openssl rand -hex 32";
      MEILI_ADDR = "http://meiliseach:7700";
      MEILI_MASTER_KEY = "xxxxxx";
      NEXTAUTH_URL = "https://karakeep.example.com";
    };
    volumes = [
      "karakeep_data:/data:rw"
    ];
    ports = [
      "127.0.0.1:32189:3000"
    ];
  };
}
