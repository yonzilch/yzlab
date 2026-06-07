_: {
  perSystem = {pkgs, ...}: {
    packages = {
      river = pkgs.callPackage ./river {};
      xl = pkgs.callPackage ./xl {};
    };
  };
}
