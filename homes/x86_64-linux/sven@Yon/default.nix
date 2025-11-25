{ pkgs, ... }:

{
  holynix.desktop = {
    plasma = {
      enable = true;
      cursorFlavour = "latte";
      cpuRange = 1600;
      launchers = [
        "applications:org.kde.dolphin.desktop"
        "preferred://browser"
        "applications:com.logseq.Logseq.desktop"
        "applications:virt-manager.desktop"
      ];
      enableGPUSensor = true;
    };
  };

  home.shellAliases = {
    "ts" = "cd /home/sven/Documents/TS/Unterricht";
    "pc" = "podman compose";
    "sls" = "live-server -o";
    "nd" = "nix develop";
  };
  programs.zsh.enable = true;
  # Add extgra packages
  home.packages = with pkgs; [
    # Crypto
    ccrypt

    #nix config
    sops

    # fun
    sl
    asciiquarium-transparent
    tetris

    # School
    gcc
    live-server
    mysql-workbench

    # Nextcloud
    nextcloud-client
  ];
}
