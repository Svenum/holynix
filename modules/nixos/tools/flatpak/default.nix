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
  usersCfg = config.holynix.users;
  plasmaCfg = config.holynix.desktop.plasma;

  mkUserConfig = _name: user: {
    imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

    home.activation = lib.mkIf (if builtins.hasAttr "isGuiUser" user then user.isGuiUser else false) {
      configureFlatpak = ''
        if [[ ! -h "$HOME/.icons" ]]; then
          ln -s /var/run/current-system/sw/share/icons $HOME/.icons
        fi
        if [[ ! -h "$HOME/.themes" ]]; then
          ln -s /var/run/current-system/sw/share/themes $HOME/.themes 
        fi
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
          Environment.XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
          Context.fileSystems = [
            "~/.themes:ro"
            "~/.icons:ro"
            "/nix/store:ro"
          ];
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
  };
}
