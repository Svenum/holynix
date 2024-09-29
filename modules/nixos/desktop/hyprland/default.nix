{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.desktop.hyprland;
in
{
  options.holynix.desktop.hyprland = {
    enable = mkOption {
      default = false;
      type = bool;
      description = "Enable hyprland window manager";
    };
  };

  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    programs.hyprlock.enable = true;
    services.hypridle.enable = true;

    environment.systemPackages = with pkgs; [
      kitty
    ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
