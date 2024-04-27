{ pkgs, lib, host, ... }:

let
  enableNixVirt = if host == "Yon" then true else false;
in
{
  imports = [ ./plasma.nix ];

  # Add extgra packages
  home.packages = with pkgs; [
    ccrypt
  ];
}
