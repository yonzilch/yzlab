{
  hostname,
  lib,
  ...
}:
with lib; {
  networking = {
    dhcpcd.extraConfig = "nohook resolv.conf";
    firewall = {
      enable = mkDefault true;
      allowedTCPPorts = [443];
      allowedUDPPorts = [443];
      logRefusedConnections = false;
    };
    hostName = hostname;
    nameservers = [
      "127.0.0.1"
      "::1"
    ];
    nftables.enable = true;
    resolvconf.enable = mkForce false;
    usePredictableInterfaceNames = mkDefault false;
  };
}
