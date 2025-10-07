{ config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.theme;
in
{
  options.holynix.theme = {
    name = mkOption {
      type = enum [ "catppuccin" ];
      default = "catppuccin";
    };
    flavor = mkOption {
      type = enum [ "mocha" "macchiato" "frappe" "latte" ];
      default = "mocha";
    };
    accent = mkOption {
      type = enum [ "rosewater" "flamingo" "pink" "mauve" "red" "maroon" "peach" "yellow" "green" "teal" "sky" "sapphire" "blue" "lavender" ];
      default = "teal";
    };
  };

  config = {
    catppuccin = {
      enable = true;
      inherit (cfg) flavor;
      inherit (cfg) accent;
    };
  };
}
