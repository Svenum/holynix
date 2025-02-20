{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.default;
in
{
  options.holynix.default.enable = mkOption {
    default = true;
    type = bool;
  };

  config = mkIf cfg.enable {
    fonts.packages = with pkgs.nerd-fonts; [
      noto
    ];
  };
}
