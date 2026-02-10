_: {
  virtualisation.oci-containers.containers."voidauth" = {
    image = "voidauth/voidauth:latest";
    environment = {
      # see https://voidauth.app/#/Getting-Started?id=environment-variables
      "APP_URL" = "https://auth.example.com";
    };
    volumes = [
      "voidauth_config:/app/config"
    ];
    ports = [
      "127.0.0.1:47126:3000"
    ];
  };
}
