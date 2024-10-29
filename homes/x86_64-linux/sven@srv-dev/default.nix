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
    attic-client
    sops
  ];
}
