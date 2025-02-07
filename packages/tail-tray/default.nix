{
  lib,
  fetchFromGitHub,
  davfs2,
  cmake,
  stdenv,
  pkg-config,
  kdePackages,
}:

stdenv.mkDerivation rec {
  name = "tail-tray";
  version = "0.2.9";

  src = fetchFromGitHub {
    owner = "SneWs";
    repo = "tail-tray";
    tag = "v${version}";
    sha256 = "sha256-jNnYJE7AbtTaXQoB165cKIqtx+t78GJOCt/HqVe9x+M=";
  };

  nativeBuildInputs = with kdePackages; [
    wrapQtAppsHook
    qttools
  ];

  buildInputs = with kdePackages; [
    cmake
    pkg-config
    qtbase
    davfs2
  ];

  postFixupPhase = ''
    substituteInPlace $out/share/applications/tail-tray.desktop \
        --replace '/usr/local' $out
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
