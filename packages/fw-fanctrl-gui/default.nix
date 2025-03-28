{
  lib,
  python3Packages,
  python3,
  fw-ectool,
  fetchFromGitHub,
  holynix
}:

python3Packages.buildPythonPackage rec{
  pname = "fw-fanctrl-gui";
  version = "0-unstable-2025-03-28";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "leopoldhub";
    repo = "fw-fanctrl-gui";
    rev = "master";
    hash = "sha256-QUWAUCVpeBvYqJ13y3iziC1B5420p1Bf2OE3yXc3TOE=";
  };

  nativeBuildInputs = [
    python3
  ];

  propagatedBuildInputs = with python3Packages; [
    setuptools
    pystray
    blinker
  ];

  doCheck = false;

  meta = with lib; {
    mainProgram = "fw-fanctrl-gui";
    homepage = "https://github.com/leopoldhub/fw-fanctrl-gui";
    description = "A simple multiplatform customtkinter python GUI and to interact with the fw-fanctrl CLI";
    platforms = lib.platforms.linux;
    license = licenses.bsd3;
    maintainers = [ lib.maintainers.Svenum ];
  };
}
