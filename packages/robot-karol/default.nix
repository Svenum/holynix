{ lib
, fetchzip
, stdenv
, makeWrapper
, jre
}:

stdenv.mkDerivation rec {
  pname = "RobotKarol";
  version = "3.0";
  src = fetchzip {
    url = "https://mebis.bycs.de/assets/uploads/mig/2_2019_10_RobotKarol30_other.zip";
    hash = "sha256-NRV9NNh2OejzUPzzlD9UvECEqFOu6Q9UYFthrWuqZR0=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/share/java $/bin
    cp $src/RobotKarol.jar $out/share/java/RobotKarol.jar
    makeWrapper ${jre}/bin/java $out/bin/RobotKarol \
      --add-flags "-jar $out/share/java/RobotKarol.jar" \
      --set _JAVA_OPTIONS '-Dawt.useSystemAAFontSettings=on'
  '';

  meta = {
    homepage = "https://mebis.bycs.de/beitrag/robot-karol";
    description = "Robot Karol is a programming environment with a language designed to help students learn programming.";
    maintainers = [ stdenv.lib.maintainers.Svenum ];
  };
}
