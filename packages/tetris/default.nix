{ pkgs }:

pkgs.haskellPackages.callPackage (
{
  mkDerivation,
  fetchgit,
  lib,

  base,
  vty,
  lens,
  brick,
  linear,
  containers,
  random,
  transformers,
  directory,
  filepath,
  optparse-applicative,
  vty-crossplatform,
  mtl,
  extra
}:
mkDerivation {
  pname = "tetris";
  version = "0.1.6";
  src = fetchgit {
    url = "https://github.com/Samtay/tetris.git";
    sha256 = "sha256-jkzSoAQWeSEG91GWe3WFpLZwK1JK3WWDQkHxeyG4OJ4=";
    rev = "0.1.6";
    fetchSubmodules = true;
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base brick containers extra lens linear mtl random transformers vty
    vty-crossplatform
  ];
  executableHaskellDepends = [
    base directory filepath optparse-applicative
  ];
  homepage = "https://github.com/samtay/tetris#readme";
  license = lib.licenses.bsd3;
  mainProgram = "tetris";
}) {}

