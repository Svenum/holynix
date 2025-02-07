{ lib
, fetchFromGitHub
, davfs2
, cmake
, stdenv
, pkg-config
, kdePackages
}:

stdenv.mkDerivation rec {
  name = "tail-tray";
  version = "v0.2.9";

  src = fetchFromGitHub {
    owner = "SneWs";
    repo = "tail-tray";
    rev = version;
    sha256 = "sha256-jNnYJE7AbtTaXQoB165cKIqtx+t78GJOCt/HqVe9x+M=";
  };

  nativeBuildInputs = with kdePackages; [
    cmake
    pkg-config
    qtbase
    wrapQtAppsHook
    qttools
  ];

  extraBuildInputs = [
    davfs2
  ];

  fixupPhase = ''
    substituteInPlace $out/share/applications/tail-tray.desktop --replace '/usr/local' $out
  '';

  meta = {
    description = "Tray icon to manage Tailscale";
    homepage = "https://github.com/SneWs/tail-tray";
    changelog = "https://github.com/SneWs/tail-tray/releases/tag/${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Svenum ];
    platforms = lib.platforms.linux;
  };
}
