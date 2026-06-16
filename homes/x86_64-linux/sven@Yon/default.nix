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

  programs.zsh.enable = true;
  home = {
    shellAliases = {
      "ts" = "cd /home/sven/Documents/TS/Unterricht";
      "pc" = "podman compose";
      "nd" = "nix develop";
    };

    packages = with pkgs; [
      # Crypto
      ccrypt

      #nix config
      sops

      # nixpkgs development
      nixpkgs-review
      gh

      # fun
      sl
      asciiquarium-transparent
      tetris

      # KI
      claude-code
      ollama-rocm

      # Nextcloud
      nextcloud-client
    ];

    stateVersion = "26.11";
  };
}
