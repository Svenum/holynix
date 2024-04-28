{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.tools.flatpak;
  themeCfg = config.holynix.theme;
  usersCfg = config.holynix.users;
  plasmaCfg = config.holynix.desktop.plasma;

  mkUserConfig = name: user: {
    home.activation = lib.mkIf (if builtins.hasAttr "isGuiUser" user then user.isGuiUser else false){
      configureFlatpak = ''
        FLAVOUR=${themeCfg.flavour}
        ACCENT=${themeCfg.accent}
        ${pkgs.flatpak}/bin/flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        ${pkgs.flatpak}/bin/flatpak remote-add --user --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
        ${pkgs.flatpak}/bin/flatpak override --user --filesystem=xdg-config/gtk-3.0:ro --filesystem=xdg-config/gtkrc-2.0:ro --filesystem=xdg-config/gtk-4.0:ro --filesystem=xdg-config/gtkrc:ro --filesystem=~/.themes:ro
        ${pkgs.flatpak}/bin/flatpak override --user --env=GTK_THEME=Catppuccin-''${FLAVOUR^}-Standard-''${ACCENT^}-${if themeCfg.flavour != "latte" then "Dark" else "Light"}
        ${pkgs.flatpak}/bin/flatpak override --user --device=dri --filesystem=~/Games:rw com.valvesoftware.Steam
        ${pkgs.rsync}/bin/rsync -vrkL /run/current-system/sw/share/themes/* ~/.themes/
      '';
    };
  };
in
{
  options.holynix.tools.flatpak = {
    enable = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # Install cusotm scripts
    environment.systemPackages = with pkgs; [
      # Theming
      betterdiscordctl
      spicetify-cli
      holynix.prepare-spotify
      (holynix.prepare-discord.override {
        accent = themeCfg.accent;
      })
    ] ++ lists.optionals plasmaCfg.enable [ pkgs.kdePackages.discover pkgs.kdePackages.packagekit-qt ];

    # Install and enable flatpak
    services.flatpak.enable = true;
    xdg.portal.enable = true;

    # Add repo and add overrides for guiUsers
    home-manager.users = lib.mapAttrs mkUserConfig usersCfg;
  };
}


