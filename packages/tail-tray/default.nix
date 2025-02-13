{
  lib,
  fetchFromGitHub,
  davfs2,
  cmake,
  stdenv,
  fetchpatch,
  pkg-config,
  kdePackages,
}:

stdenv.mkDerivation rec {
  name = "tail-tray";
  version = "0.2.11";

  src = fetchFromGitHub {
    owner = "SneWs";
    repo = "tail-tray";
    tag = "v${version}";
    sha256 = "sha256-khJX/zsbDgT+eJVhIR72i8kYGJVoUEngfjZp/TASa/4=";
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

  postFixup = ''
    substituteInPlace $out/share/applications/tail-tray.desktop \
      --replace-fail '/usr/local' $out
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
