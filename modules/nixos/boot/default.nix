{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.boot;
in
{
  options.holynix.boot = {
    enable = mkOption {
      type = bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # Filesystems
    boot.supportedFilesystems = [ "ntfs" ];

    # Kernel
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    # Bootloader
    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 15;
      };
      efi.canTouchEfiVariables = true;
      timeout = mkDefault 1;
    };

    boot.initrd.systemd.enable = true;
    boot.kernelParams = [ "quiet" "udev.log_level=3" ];

    # Configure Plymouth
    boot.plymouth = {
      enable = true;
      theme = "catppuccin-${config.holynix.theme.flavour}";
      themePackages = with pkgs; [
        (catppuccin-plymouth.override {
          variant = config.holynix.theme.flavour;
        })
      ];
    };
  };
}
