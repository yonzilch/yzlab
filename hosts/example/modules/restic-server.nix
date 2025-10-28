{pkgs, ...}: {
  services.restic.server = {
    enable = true;
    # use command `nix-shell -p apacheHttpd`
    # `htpasswd -n -B foobar` to generate
    htpasswd-file = "${pkgs.writeText "htpasswd" ''
      foobar:xxxxxx
    ''}";
    listenAddress = "127.0.0.1:24631";
  };
}
