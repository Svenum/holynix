{ pkgs, lib, host, ... }:

let
  enableNixVirt = if host == "Yon" then true else false;
in
{
  imports = [ ./plasma.nix ];

  home.shellAliases = {
    "ts" = "cd /home/sven/Documents/TS/Unterricht";
    "pc" = "podman compose";
  };
  # Add extgra packages
  home.packages = with pkgs; [
    ccrypt

    holynix.bycsdrive
    holynix.robot-karol
  ];
}
