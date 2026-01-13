{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.tools.flatpak;
  themeCfg = config.holynix.theme;
  usersCfg = config.holynix.users;
  plasmaCfg = config.holynix.desktop.plasma;

  flavor = "${lib.toUpper (builtins.substring 0 1 themeCfg.flavor)}${
    builtins.substring 1 99 themeCfg.flavor
  }";
  accent = "${lib.toUpper (builtins.substring 0 1 themeCfg.accent)}${
    builtins.substring 1 99 themeCfg.accent
  }";
  mode = if themeCfg.flavor != "latte" then "Dark" else "Light";

  mkUserConfig = _name: user: {
    imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

    home.activation = lib.mkIf (if builtins.hasAttr "isGuiUser" user then user.isGuiUser else false) {
      configureFlatpak = ''
        ${
          if plasmaCfg.enable then
            (pkgs.rsync + "/bin/rsync -vrkL /run/current-system/sw/share/themes/* ~/.themes/")
          else
            ""
        }
      '';
    };

    services.flatpak = {
      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
        {
          name = "flathub-beta";
          location = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
        }
      ];
      overrides = {
        global = {
          Context.fileSystems = [
            "xdg-config/gtk-3.0:ro"
            "xdg-config/gtkrc-2.0:ro"
            "xdg-config/gtk-4.0:ro"
            "xdg-config/gtkrc:ro"
            "~/.themes:ro"
          ];
          Environment.GTK_THEME = "Catppuccin-${flavor}-Standard-${accent}-${mode}";
        };
      };
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
    environment.systemPackages = mkIf plasmaCfg.enable [
      pkgs.kdePackages.discover
      pkgs.kdePackages.packagekit-qt
    ];

    # Install and enable flatpak
    services.flatpak.enable = true;
    xdg.portal.enable = true;

    # Add repo and add overrides for guiUsers
    home-manager.users = lib.mapAttrs mkUserConfig usersCfg;

    # Fix fonts
    fonts.fontDir.enable = true;
    system.fsPackages = [ pkgs.bindfs ];
    fileSystems =
      let
        mkRoSymBind = path: {
          device = path;
          fsType = "fuse.bindfs";
          options = [
            "ro"
            "resolve-symlinks"
            "x-gvfs-hide"
          ];
        };
        aggregatedFonts = pkgs.buildEnv {
          name = "system-fonts";
          paths = config.fonts.packages;
          pathsToLink = [ "/share/fonts" ];
        };
      in
      {
        "/usr/local/share/fonts" = mkRoSymBind "${aggregatedFonts}/share/fonts";
      };
  };
}
