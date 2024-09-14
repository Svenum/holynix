{ lib
, fetchzip
, stdenv
, makeWrapper
, jre
, makeDesktopItem
, unzip
, imagemagick
}:

stdenv.mkDerivation rec {
  pname = "RobotKarol";
  version = "3.0";
  src = fetchzip {
    url = "https://mebis.bycs.de/assets/uploads/mig/2_2019_10_RobotKarol30_other.zip";
    hash = "sha256-NRV9NNh2OejzUPzzlD9UvECEqFOu6Q9UYFthrWuqZR0=";
    stripRoot = false;
  };
  
  desktopItem = makeDesktopItem {
    name = pname;
    exec = "RobotKarol";
    terminal = false;
    desktopName = "Robot Karol";
    icon = "Karol";
  };

  nativeBuildInputs = [
    makeWrapper
    unzip
    imagemagick
  ];

  installPhase = ''
    mkdir -p $out/share/java $/bin

    # Unpack jar for icon file
    unpackDir="$TMPDIR/unpack"
    mkdir "$unpackDir"
    cd "$unpackDir"
    cp $src/RobotKarol.jar $TMPDIR/RobotKarol.zip
    unpackFile $TMPDIR/RobotKarol.zip
    magick -background transparent $TMPDIR/unpack/icons/Karol.ico $TMPDIR/unpack/icons/Karol.png

    cp $src/RobotKarol.jar $out/share/java/RobotKarol.jar
    makeWrapper ${jre}/bin/java $out/bin/RobotKarol \
      --add-flags "-jar $out/share/java/RobotKarol.jar" \
      --set _JAVA_OPTIONS '-Dawt.useSystemAAFontSettings=on'
    install -D $TMPDIR/unpack/icons/Karol.png $out/share/icons/hicolor/32x32/apps/Karol.png
    install -D -t $out/share/applications $desktopItem/share/applications/*
  '';

  meta = {
    homepage = "https://mebis.bycs.de/beitrag/robot-karol";
    description = "Robot Karol is a programming environment with a language designed to help students learn programming.";
    maintainers = [ stdenv.lib.maintainers.Svenum ];
  };
}
