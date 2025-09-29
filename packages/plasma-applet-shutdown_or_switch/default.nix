{ lib, stdenvNoCC, fetchFromGitHub, ... }:

stdenvNoCC.mkDerivation {
  pname = "plasma-applet-shutdown_or_switch";
  version = "21.03.2024";

  src = fetchFromGitHub {
    owner = "Davide-sd";
    repo = "shutdown_or_switch";
    rev = "master";
    sha256 = "sha256-S28mE4LpDuUghWwODqGF/MIIaPnqRcfRdOrvuQ87jJ8=";
    #owner = "Svenum";
    #repo = "shutdown_or_switch";
    #rev = "add-second-hibernate-option";
    #sha256 = "sha256-WRHGwYmNTyfo6QWIKfjKMivq9tmisoSZ/FGCD0uUGKI=";
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
