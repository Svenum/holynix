{ pkgs, lib, host, config, ... }:

let
  enableNixVirt = if host == "Yon" then true else false;
in
{
  imports = []
    ++ lib.lists.optional config.holynix.desktop.plasma.enable ./plasma.nix;

  home.shellAliases = {
    "ts" = "cd /home/sven/Documents/TS/Unterricht";
    "pc" = "podman compose";
    "sls" = "live-server -o";
  };
  programs.zsh.enable = true;
  # Add extgra packages
  home.packages = with pkgs; [
    ccrypt

    sl

    gcc

    live-server

    holynix.bycsdrive
    holynix.robot-karol
  ];
}
