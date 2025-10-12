{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "komari-server";
  version = "1.1.1b";
  src = fetchurl {
    url = "https://github.com/komari-monitor/komari/releases/download/1.1.1b/komari-linux-amd64";
    sha256 = "sha256-HpFdaa9tCBnDYsBxRuQtnZUEDMZK7Fws74Sn0pq6JfY=";
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
    maintainers = [yonzilch];
  };
}
