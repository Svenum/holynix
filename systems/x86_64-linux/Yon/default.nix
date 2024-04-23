{ pkgs, lib, config, ... }:

{
  imports = [
    ./hardware.nix
  ];

  holynix = {
    users."sven" = {
      isGuiUser = true;
      isSudoUser = true;
      git = {
        userName = "Svenum";
        userEmail = "s.ziegler@holypenguin.net";
      };
    };
  };

  # enable solaar
  programs.solaar.enable = true;
  
  # Enable Waydroid
  virtualisation.waydroid.enable = true;

  # Nix config
  nixpkgs.config.allowUnfree = true;
}
