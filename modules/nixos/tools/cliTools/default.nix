{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.tools.cliTools;
in
{
  options.holynix.tools.cliTools = {
    enable = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    environment.shellAliases = {
      pbpaste = "xsel --output --clipboard";
      pbcopy = "xsel --input --clipboard";
    };

    environment.systemPackages = with pkgs; [
      # CLI Packages
      git
      wget
      tree
      unzip
      pciutils
      usbutils
      clinfo
      killall
      neofetch
      cifs-utils
      btop
      dig
      rclone
      xsel
      # Scripts
      holynix.backup
    ];
  };
}
