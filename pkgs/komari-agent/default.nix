{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "komari-agent";
  version = "1.1.31";
  src = fetchurl {
    url = "https://github.com/komari-monitor/komari-agent/releases/download/1.1.31/komari-agent-linux-amd64";
    sha256 = "sha256-pYzS+FRNMCzJuXAjF9P7d0Ji1B1HVN21c2JELhRWaWU=";
  };
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp $src $out/bin/komari-agent
    chmod +x $out/bin/komari-agent
    runHook postInstall
  '';
  meta = with lib; {
    description = "komari agent";
    homepage = "https://github.com/komari-monitor/komari-agent";
    license = licenses.free;
    platforms = ["x86_64-linux"];
    maintainers = [maintainer.yonzilch];
  };
}
