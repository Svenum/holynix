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

  home.shellAliases = {
    "pc" = "podman compose";
  };
  programs.zsh.enable = true;
  # Add extgra packages
  home.packages = with pkgs; [
    #nix config
    sops
  ];
}
