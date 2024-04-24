{ lib, stdenvNoCC, fetchgit, ... }:

stdenvNoCC.mkDerivation {
  pname = "konsole-catppuccin";
  version = "09.11.2022";

  src = fetchgit {
    url = "https://github.com/catppuccin/konsole.git";
    rev = "7d86b8a1e56e58f6b5649cdaac543a573ac194ca";
    sha256 = "sha256-EwSJMTxnaj2UlNJm1t6znnatfzgm1awIQQUF3VPfCTM=";
  };

  installPhase = ''
    mkdir -p $out/share/konsole
    cp -r $src/Catppuccin-*.colorscheme $out/share/konsole/
    for scheme in $(ls $out/share/konsole); do
      substituteInPlace $out/share/konsole/$scheme --replace "Opacity=1" "Opacity=0.95"
    done
    cp ${./profile}/* $out/share/konsole/
  '';

  meta = with lib; {
    homepage = "https://github.com/catppuccin/konsole";
    license = lib.licenses.mit;
  };
}
