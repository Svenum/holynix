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
    owner = "leopoldhub";
    repo = "fw-fanctrl";
    rev = "true-pip-installation";
    hash = "sha256-+32ahFbziOubIj3ifOMXGdwi7Er+b2mQDI99WaMjRQ0=";
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
    cp $src/src/fw_fanctrl_setup/_resources/services/system-sleep/fw-fanctrl-suspend $out/share/fw-fanctrl/fw-fanctrl-suspend
    substituteInPlace $out/share/fw-fanctrl/fw-fanctrl-suspend \
      --replace-fail '#!/bin/sh' '#!/usr/bin/env sh' \
      --replace-fail '%PYTHON_PATH% "%PYTHON_SCRIPT_INSTALLATION_PATH%"' $out/bin/fw-fanctrl
    # Cleanup
    rm -rf $out/bin/fw-fanctrl-setup $out/lib/python3.12/site-packages/fw_fanctrl_setup
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

