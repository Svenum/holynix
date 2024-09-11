{ lib
, appimageTools
, fetchurl
}:

appimageTools.wrapType2 {
  name = "bycsdrive";
  src = fetchurl {
    url = "https://desktop-client-download.drive.bycs.de/download/5.2.0.12891/bycsdrive-5.2.0.12891-x86_64.AppImage";
    hash = "sha256-h/1N+1m4PGOWRNBMVNY6CCe3ezd7/I7Av5DCS8cVot0=";
  };
  extraPkgs = pkgs: with pkgs; [ ];
}
