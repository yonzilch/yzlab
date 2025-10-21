{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "komari-server";
  version = "1.1.2a";
  src = fetchurl {
    url = "https://github.com/komari-monitor/komari/releases/download/1.1.2a/komari-linux-amd64";
    sha256 = "sha256-C5XQQP8mziHqPCIu7A4SMWJkxRhp+6z+F38dxZLVjmw=";
  };
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp $src $out/bin/komari
    chmod +x $out/bin/komari
    runHook postInstall
  '';
  meta = with lib; {
    description = "A simple server monitor tool.";
    homepage = "https://github.com/komari-monitor/komari";
    license = licenses.free;
    platforms = ["x86_64-linux"];
    maintainers = [maintainer.yonzilch];
  };
}
