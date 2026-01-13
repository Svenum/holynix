{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:

stdenvNoCC.mkDerivation rec {
  pname = "shutdown_or_switch";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "Davide-sd";
    repo = "shutdown_or_switch";
    rev = "v${version}";
    hash = "sha256-nCSHYBQcw6Ids/+xwqz2vfn8TaLTUNhP86kMUluMWN0=";
  };

  installPhase = ''
    mkdir -p $out/share/plasma/plasmoids/
    cp -r $src/package $out/share/plasma/plasmoids/org.kde.plasma.shutdownorswitch
  '';

  meta = with lib; {
    homepage = "https://github.com/Davide-sd/shutdown_or_switch";
    license = lib.licenses.gpl2Only;
  };
}
