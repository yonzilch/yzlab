{lib, ...}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "terraria-server"
    ];
  services.terraria = {
    enable = true;
    autoCreatedWorldSize = "large";
    openFirewall = true;
  };
}
