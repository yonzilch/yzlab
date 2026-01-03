_: {
  perSystem = {pkgs, ...}: {
    packages = {
      river = pkgs.callPackage ./river {};
    };
  };
}
