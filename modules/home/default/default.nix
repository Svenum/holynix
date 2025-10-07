{ config, lib, ... }:

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
    holynix.tools = {
      nvim.enable = mkDefault true;
      tmux.enable = mkDefault true;

    };
  };
}
