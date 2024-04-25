{ pkgs }:

pkgs.writeShellScriptBin "backup" (builtins.readFile ./script.sh)
