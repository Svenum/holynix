{ options, config, lib, ... }:

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
            /run/wrappers/bin/su $@
          else
            sudo -s
          fi
        }
    '';
  };
}
