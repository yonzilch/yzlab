{
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "xl";
  version = "v0.6.0-xdp";

  src = fetchurl {
    url = "https://github.com/undead-undead/xray-lite/releases/download/${version}/xray-linux-amd64-xdp";
    sha256 = "sha256-9v3yLxXG+bx3zAkNIlTfjAujd7cAhtDbsLIc5s7ZWqc=";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm755 $src $out/bin/xl
  '';
}
