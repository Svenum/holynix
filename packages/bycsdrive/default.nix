{ lib
, appimageTools
, fetchurl
}:

let
  name = "bycsdrive";
  src = fetchurl {
    url = "https://desktop-client-download.drive.bycs.de/download/5.2.0.12891/bycsdrive-5.2.0.12891-x86_64.AppImage";
    hash = "sha256-h/1N+1m4PGOWRNBMVNY6CCe3ezd7/I7Av5DCS8cVot0=";
  };

  appimageContents = appimageTools.extractType2 {inherit name src;};
in
appimageTools.wrapType2 rec {
  inherit name src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/bycsdrive.desktop $out/share/applications/bycsdrive.desktop
    install -m 444 -D ${appimageContents}/bycsdrive.png $out/share/icons/hicolor/512x512/apps/bycsdrive.png
  '';
}
