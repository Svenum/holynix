{ options, config, lib, ... }:

let
  cfg = config.holynix.theme;
in
{
  options.holynix.theme = {
    name = lib.mkOption {
      type = lib.types.enum [ "catppuccin" ];
      default = "catppuccin";
    };
    flavour = lib.mkOption {
      type = lib.types.enum [ "mocha" "macchiato" "frappe" "latte" ];
      default = "mocha";
    };
    accent = lib.mkOption {
      type = lib.types.enum [ "rosewater" "flamingo" "pink" "mauve" "red" "maroon" "peach" "yellow" "green" "teal" "sky" "sapphire" "blue" "lavender" ];
      default = "teal";
    };
  };
}
