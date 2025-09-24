{
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "river";
  version = "v0.5.0";
  src = fetchurl {
    url = "https://github.com/memorysafety/river/releases/download/v0.5.0/river-x86_64-unknown-linux-musl.tar.xz";
    sha256 = "sha256-Ypb/2wsu7yeoJ6dxm+hPvx+pRabWZ/NxrBqq2Fd3mQQ=";
  };
  unpackPhase = ''
    tar xf ${src}
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp river-x86_64-unknown-linux-musl/river $out/bin/
  '';
}
