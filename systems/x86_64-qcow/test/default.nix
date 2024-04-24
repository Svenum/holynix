{ pkgs, lib, config, ... }:

{
  imports = [ ./hardware.nix ];

  holynix = {
    desktop.plasma.enable = true;
    locale = "en_DE";
    users."sven" = {
      isGuiUser = true;
      isSudoUser = true;
      password = "test";
      git = {
        userName = "Svenum";
        userEmail = "s.ziegler@holypenguin.net";
      };
    };
  };
}
