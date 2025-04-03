{ lib
, python3Packages
, python3
, fw-ectool
, fetchFromGitHub
}:

python3Packages.buildPythonPackage rec {
  pname = "fw-fanctrl";
  version = "0-unstable-2025-04-03";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "TamtamHero";
    repo = "fw-fanctrl";
    rev = "main";
    hash = "sha256-WBP9Z+M1WmVOWNeDMIoGxOe/k0EOgWbOrNCR6fGYf34=";
  };

  nativeBuildInputs = [
    python3
  ];

  propagatedBuildInputs = with python3Packages; [
    fw-ectool
    setuptools
    jsonschema
  ];

  postInstall = ''
    mkdir -p $out/share/fw-fanctrl
    cp $src/src/fw_fanctrl/_resources/config.json $out/share/fw-fanctrl/config.json
    cp $src/services/system-sleep/fw-fanctrl-suspend $out/share/fw-fanctrl/fw-fanctrl-suspend
    substituteInPlace $out/share/fw-fanctrl/fw-fanctrl-suspend \
      --replace-fail '#!/bin/sh' '#!/usr/bin/env sh' \
      --replace-fail '/usr/bin/python3 "%PYTHON_SCRIPT_INSTALLATION_PATH%"' $out/bin/fw-fanctrl
  '';

  doCheck = false;

  meta = with lib; {
    mainProgram = "fw-fanctrl";
    homepage = "https://github.com/TamtamHero/fw-fanctrl";
    description = "Simple systemd service to better control Framework Laptop's fan(s)";
    platforms = lib.platforms.linux;
    license = licenses.bsd3;
    maintainers = [ lib.maintainers.Svenum ];
  };
}

