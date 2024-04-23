{ pkgs, lib, config, ... }:

{
  imports = [
    ./hardware.nix
  ];

  holynix = {
  };

  # enable solaar
  programs.solaar.enable = true;
  
  # Enable Waydroid
  virtualisation.waydroid.enable = true;

  # Nix config
  nixpkgs.config.allowUnfree = true;
}
