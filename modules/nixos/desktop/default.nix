{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;

let
  cfg = config.holynix.desktop;
  localeCfg = config.holynix.locale;
in
{
  options.holynix.desktop = {
    enable = mkOption {
      type = bool;
      default = if cfg.plasma.enable then true else false;
    };

    wayland = mkOption {
      type = bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # Configure Fonts
    fonts = {
      packages = with pkgs; [
        noto-fonts-cjk-sans
        noto-fonts-lgc-plus
      ];
      enableDefaultPackages = true;
    };

    # Configure sound
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Add Catppuccin wallpaper
    environment.etc.wallpaper.source = ./images;

    # set Hibernate delay
    systemd.sleep.extraConfig = ''
      HibernateDelaySec=300
    '';

  };
}
