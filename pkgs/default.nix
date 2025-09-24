_: {
  perSystem = {pkgs, ...}: {
    packages = {
      river = pkgs.callPackage ./river {};
      komari-agent = pkgs.callPackage ./komari-agent {};
      komari-server = pkgs.callPackage ./komari-server {};
    };
  };
}
