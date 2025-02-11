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
  version = "0.2.10";

  src = fetchFromGitHub {
    owner = "SneWs";
    repo = "tail-tray";
    tag = "v${version}";
    sha256 = "sha256-60ddnIyW93TKHlZ4PgW1ggoyN4moHJEiQ9FnnL6cM7Q=";
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

  patches = [
    # Fixes https://github.com/SneWs/tail-tray/issues/33
    (fetchpatch {
      url = "https://github.com/SneWs/tail-tray/commit/d7655e2187f6a445bd046d0b6fc766387a4d55b7.diff";
      hash = "sha256-hyf3f8A8hxx2WFsh0eYb4meytg0TpOh9nZAUAtL0jsY=";
    })
    # Fiexes https://github.com/SneWs/tail-tray/issues/37
    (fetchpatch {
      url = "https://github.com/SneWs/tail-tray/commit/83719c629ea98a035ff937a819d6c493f5a7c032.patch";
      hash = "sha256-oqePwgo+ejhnwh3RZ8+gnwOV2M7w/q04cc16nuQVI3E=";
    })
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
