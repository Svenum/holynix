{ pkgs, lib, host, systemConfig, ... }:

let
  enableNixVirt = if host == "Yon" then true else false;
  isYon = host == "Yon";
  issrv-nixostest = host == "srv-nixostest";
in
{
  holynix.desktop = {
    hyprland = {
      enable = true;
      monitors = [
        "DP-3,2560x1440@100,3440x0,auto"
        "DP-4,3440x1440@100,0x0,auto"
      ];
    };
    plasma = {
      enable = true;
      cursorFlavour = "latte";
      cpuRange =if isYon then
          1600
        else if issrv-nixostest then
          400
        else
          100; 
    };
  };

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
