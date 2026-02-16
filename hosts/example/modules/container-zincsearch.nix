_: {
  virtualisation.oci-containers.containers."zincsearch" = {
    image = "public.ecr.aws/zinclabs/zincsearch:latest";
    pull = "newer";

    environment = {
      ZINC_DATA_PATH = "/data";
      ZINC_FIRST_ADMIN_USER = "foobar";
      ZINC_FIRST_ADMIN_PASSWORD = "xxxxxx";
    };

    volumes = [
      "zincsearch:/data"
    ];

    ports = [
      "127.0.0.1:4080:4080"
    ];
  };
}
