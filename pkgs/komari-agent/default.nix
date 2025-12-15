{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "komari-agent";
  version = "1.1.40";
  src = fetchurl {
    url = "https://github.com/komari-monitor/komari-agent/releases/download/1.1.40/komari-agent-linux-amd64";
    sha256 = "sha256-4/G/Uf7cNE2eWb4rZYjw94E86wmEgINYOi13LhVI8R0=";
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
