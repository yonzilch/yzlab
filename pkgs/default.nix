_: {
  perSystem = {pkgs, ...}: {
    packages = {
      river = pkgs.callPackage ./river {};
      komari-server = pkgs.callPackage ./komari-server {};
    };
  };
}
