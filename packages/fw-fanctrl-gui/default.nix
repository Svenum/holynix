{ lib
, python3Packages
, python3
, fetchFromGitHub
, inputs
}:

let
  customtkinter = python3Packages.buildPythonPackage rec {
    pname = "customtkinter";
    version = "5.2.2";
    pyproject = true;

    src = fetchFromGitHub{
      owner = "tomschimansky";
      repo = "customtkinter";
      tag = "v${version}";
      hash = "sha256-1g2wdXbUv5xNnpflFLXvU39s16kmwvuegKWd91E3qm4=";
    };

    propagatedBuildInputs = with python3Packages; [
      setuptools
      darkdetect
    ];
  };

  pygubu = python3Packages.buildPythonPackage rec {
    pname = "pygubu";
    version = "0.36";
    pyproject = true;

    src = fetchFromGitHub{
      owner = "alejandroautalan";
      repo = "pygubu";
      tag = "v${version}";
      hash = "sha256-iKmSJHLpNbiVsuYnLKlbHK5911qRxqATRTMS8zO7NhM=";
    };

    propagatedBuildInputs = with python3Packages; [
      darkdetect
      setuptools
    ];
  };
in
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
    customtkinter
    pygubu
    inputs.fw-fanctrl.packages.x86_64-linux.default
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
