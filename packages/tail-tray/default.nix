{ lib
, mkKdeDerivation
, fetchFromGitHub
}

mkKdeDerivation rec {
  pname = "tail-tray";
  version = "v0.2.9";

  src = fetchFromGitHub {
    owner = "SneWe";
    repo = "tail-tray";
    rev = version
    sha256 = "";
  };
}
