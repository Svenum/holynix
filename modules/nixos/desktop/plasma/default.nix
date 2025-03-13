{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;

let
  cfg = config.holynix.desktop.plasma;
  desktopCfg  = config.holynix.desktop;
  themeCfg = config.holynix.theme;
in
{
  options.holynix.desktop.plasma = {
    enable = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # Enable default desktop settings
    holynix.desktop.enable = true;

    # Enable SDDM and Plasma
    services.displayManager = {
      sddm = {
        enable = true;
        wayland = {
          enable = true;
          compositor = "kwin";
        };
        autoNumlock = true;
      };
      defaultSession = mkIf (! desktopCfg.wayland) "plasmax11";
    };
    services.desktopManager.plasma6 = {
      enable = true;
    };

    # Disable packages
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      oxygen
      elisa
      khelpcenter
      kwrited
    ];   
    programs.dconf.enable = true;

    # Install Needed packages
    environment.systemPackages = with pkgs; [
      # XWayland compability
      xorg.xrdb
      xsettingsd
      xdg-desktop-portal-gtk
      # KDE Backup
      kdePackages.kup
      bup
      # GUI Tools
      kdePackages.sddm-kcm
      kdePackages.xwaylandvideobridge
      caffeine-ng
      kdePackages.korganizer
      kdePackages.kdepim-runtime
      kdePackages.kdepim-addons
      kdePackages.kaccounts-providers
      kdePackages.kaccounts-integration
      kdePackages.signond
      kdePackages.qtwebengine
      # Add Konsole profiles and colorshcemes
      holynix.konsole-catppuccin
      # Add plasmoids
      holynix.plasma-applet-shutdown_or_switch
      # Other
      glxinfo
      vulkan-tools
      playerctl
      wayland-utils
      aha

      # Icons
      (catppuccin-papirus-folders.override {
        flavor = "latte";
        inherit (themeCfg) accent;
        })
      # KDE Themes
      (catppuccin-kde.override {
        flavour = [ themeCfg.flavor ];
        accents = [ themeCfg.accent ];
        winDecStyles = [ "modern" ];
      })
      (catppuccin-sddm.override {
        inherit (themeCfg) flavor;
      })
      # GTK Themes
      (catppuccin-gtk.override {
        variant = themeCfg.flavor;
        accents = [ themeCfg.accent ];
      })
    ] ++ (if themeCfg.accent == "teal" then [catppuccin-cursors.latteTeal catppuccin-cursors.mochaTeal] else
          if themeCfg.accent == "red" then [catppuccin-cursors.latteRed catppuccin-cursors.mochaRed] else
          if themeCfg.accent == "peach" then [catppuccin-cursors.lattePeach catppuccin-cursors.mochaPeach] else []);

    # Enable partitionmanager
    programs.partition-manager.enable = true;

    # Enable KDEConnect
    programs.kdeconnect = {
      enable = true;
      package = lib.mkForce pkgs.kdePackages.kdeconnect-kde;
    };

    # Enable XWayland
    programs.xwayland.enable = true;
  };
}
