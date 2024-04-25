{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.shell;
in
{
  options.holynix.shell.enable = mkOption {
    type = bool;
    default = false;
  };

  config = mkIf cfg.enable {
    # Default alias
    environment.shellInit = ''
        su() {
          if [[ $1 != "" ]]; then
            ${pkgs.su}/bin/su $@
          else
            sudo -s
          fi
        }
    '';
  };
}
