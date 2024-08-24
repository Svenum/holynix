{ lib
, stdenv
, fetchFromGitHub
, gettext
, git
, makeWrapper
, nodejs
}:

stdenv.mkDerivation rec {
  pname = "cockpit-podman";
  version = "93";

  src = fetchFromGitHub {
    owner = "cockpit-project";
    repo = "cockpit-podman";
    rev = "refs/tags/${version}";
    hash = "sha256-VGy8rVP8BMEu2gj5Hd8/epDvwWz2G+X8y+PR5PCtTyI=";
    fetchSubmodules = true;
    leaveDotGit = true;
  };

  nativeBuildInputs = [
    makeWrapper
    gettext
    git
    nodejs
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Web-based graphical interface for servers and podman";
    mainProgram = "cockpit-bridge";
    homepage = "https://cockpit-project.org/";
    license = licenses.lgpl21;
    maintainers = with maintainers; [ Svenum ];
  };
}
