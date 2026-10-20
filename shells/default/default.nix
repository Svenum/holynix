{
  pkgs,
  inputs,
  mkShell,
  ...
}:
let
  pre-commit-check = inputs.git-hooks.lib.${pkgs.system}.run {
    src = ../../.;
    hooks = import ./hooks.nix;
  };
  inherit (pre-commit-check) enabledPackages shellHook;
in
mkShell {
  shellHook = ''
    ${shellHook}
    # Just start zsh if it's an interactive shell
    if [[ $- == *i* ]]; then
      exec zsh
    fi
  '';
  buildInputs = enabledPackages;
}
