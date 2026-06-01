{ pkgs, ... }:

{
  holynix.desktop = {
    plasma = {
      enable = true;
      cursorFlavour = "latte";
      cpuRange = 400;
      launchers = [
        "applications:org.kde.dolphin.desktop"
        "preferred://browser"
        "applications:org.kde.konsole.desktop"
      ];
      enableGPUSensor = false;
    };
  };

  programs.zsh.enable = true;

  home = {
    shellAliases = {
      "pc" = "podman compose";
    };

    packages = with pkgs; [
      #nix config
      sops
    ];

    stateVersion = "26.11";
  };
}
