{ pkgs, lib, host, ... }:

let
  enableNixVirt = if host == "Yon" then true else false;
in
{
  imports = [ ./plasma.nix ];

  programs.zsh.shellAliases = {
    "ts" = "cd /home/sven/Documents/TS/Unterricht";
    "pc" = "podman compose";
  };
  # Add extgra packages
  home.packages = with pkgs; [
    ccrypt

    gcc

    holynix.bycsdrive
    holynix.robot-karol
  ];
}
