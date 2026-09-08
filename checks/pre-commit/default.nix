{ inputs, pkgs, ... }:

inputs.git-hooks.lib.${pkgs.system}.run {
  src = ../..;
  hooks = {
    nixfmt.enable = true;
    statix = {
      enable = true;
      excludes = [ "docker-compose\\.nix$" ];
      settings.ignore = [ "docker-compose.nix" ];
    };
    deadnix.enable = true;
    flake-checker.enable = true;
  };
}
