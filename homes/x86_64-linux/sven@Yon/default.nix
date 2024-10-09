{ pkgs, lib, host, systemConfig, ... }:

let
  enableNixVirt = if host == "Yon" then true else false;
  isYon = host == "Yon";
  issrv-nixostest = host == "srv-nixostest";
in
{
  holynix.desktop = {
    plasma = {
      enable = true;
      cursorFlavour = "latte";
      cpuRange =if isYon then
          1600
        else if issrv-nixostest then
          400
        else
          100; 
      launchers = [
        "applications:org.kde.dolphin.desktop"
        "preferred://browser"
        "applications:com.logseq.Logseq.desktop"
        "applications:com.valvesoftware.Steam.desktop"
        "applications:net.lutris.Lutris.desktop"
      ];
      enableGPUSensor = true;
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
    # Crypto
    ccrypt
    
    #nix config
    attic-client
    sops
    
    # fun
    sl
    asciiquarium-transparent

    # School
    gcc
    live-server
    holynix.bycsdrive
    holynix.robot-karol
    mysql-workbench
  ];
}
