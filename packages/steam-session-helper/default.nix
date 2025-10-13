{ stdenvNoCC
, fetchFromGitHub
}:

stdenvNoCC.mkDerivation {
  name = "steam-session-helper";

  src = fetchFromGitHub {
    owner = "shahnawazshahin";
    repo = "steam-using-gamescope-guide";
    rev = "d3628ffde566c215e409577f0ffbe2efc91a7ead";
    hash = "sha256-Yar+oaY9udzg7C8m2Nc3x44NnHLz767nvWJ4vFWsJRg=";
  };

  dontBuild = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    cp -r $src/usr/bin/* $out/bin/
    chmod -R +x $out/bin
    patchShebangs $out/bin

    runHook postInstall
  '';
}
