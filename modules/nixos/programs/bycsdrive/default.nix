{ options, lib, config, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.programs.bycsdrive;
in
{
  options.holynix.programs.bycsdrive.enable = mkOption {
    type = bool
    default = true;
    description = "Enable bycsdrive";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.holynix.bycsdrive
    ];
  };
}
