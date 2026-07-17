_: {
  services.atftpd = {
    enable = true;
    root = "/tmp/tftp";
    extraOptions = [
      "--bind-address 0.0.0.0"
      "--verbose=7"
    ];
  };
  networking.firewall = {
    allowedUDPPorts = [ 69 ];
    extraInputRules = ''
      udp dport 69 ct helper set "tftp"
    '';
    extraCommands = ''
      nft add ct helper inet filter tftp { type "tftp" protocol udp\; }
    '';
  };
}
