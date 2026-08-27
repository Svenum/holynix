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

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [
        "qemu+ssh://holyadmin@kaeru/system"
      ];
      uris = [
        "qemu+ssh://holyadmin@kaeru/system"
      ];
    };
  };

  home = {
    shellAliases = {
      "wrx" = "cd /home/sven/Documents/Wrexham/Lessons";
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
      opencode
      ollama-rocm

      # Nextcloud
      nextcloud-client
    ];

    stateVersion = "26.11";
  };
}
