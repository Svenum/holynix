{ pkgs, lib, config, ... }:

{
  imports = [ ./hardware.nix ];

  holynix = {
    desktop.plasma.enable = true;
    locale = "en_DE";
    users."sven" = {
      isGuiUser = true;
      isSudoUser = true;
      git = {
        userName = "Svenum";
        userEmail = "s.ziegler@holypenguin.net";
      };
    };
    wireguard.enable = true;
  };

  # enable solaar
  programs.solaar.enable = true;
  
  # Enable Waydroid
  virtualisation.waydroid.enable = true;
}
