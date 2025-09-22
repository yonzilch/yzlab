_: {
  services.wakapi = {
    enable = true;
    # see https://github.com/NixOS/nixpkgs/blob/88a55dffa4d44d294c74c298daf75824dc0aafb5/nixos/modules/services/web-apps/wakapi.nix#L155
    # the passwordSaltFile would need environment file like
    # ''
    # WAKAPI_PASSWORD_SALT=xxxxxxxxxxxxxxxxxxxxx
    # ''
    settings = {
      env = "production";
      server = {
        listen_ipv4 = "127.0.0.1";
        listen_ipv6 = "-";
        port = 3000;
        base_path = "/";
        public_url = "https://wakapi.example.com";
      };
      security = {
        allow_signup = false;
        invite_codes = false;
      };
    };
  };
}
