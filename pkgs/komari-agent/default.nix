{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "komari-agent";
  version = "1.1.12";
  src = fetchurl {
    url = "https://github.com/komari-monitor/komari-agent/releases/download/1.1.12/komari-agent-linux-amd64";
    sha256 = "sha256-ykIJPFf5duRtDYX9UfS3iatUH+xRMSyo1zT2TGe1sbc=";
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
