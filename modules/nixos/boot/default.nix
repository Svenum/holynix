{ options, config, lib, pkgs, inputs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.boot;
in
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];
  
  options.holynix.boot = {
    enable = mkOption {
      type = bool;
      default = true;
      description = "enable holynix boot options";
    };
    secureBoot = mkOption {
      type = bool;
      default = false;
      description = "enable lanzaboote to enable secure boot";
    };
    systemdBoot = mkOption {
      type = bool;
      default = true;
      description = "enable systemd-boot";
    };
    memtest = mkOption {
      type = bool;
      default = false;
      description = "enable memtest86";
    };
    netboot = mkOption {
      type = bool;
      default = false;
      description = "enable netbootxyz to boot images on the network";
    };
  };

  config = mkIf cfg.enable {
    # Filesystems
    boot.supportedFilesystems = [ "ntfs" ];

    # Kernel
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    # Bootloader
    boot.loader = {
      systemd-boot = mkIf cfg.systemdBoot {
        enable = mkIf (! cfg.secureBoot) true;
        configurationLimit = 15;
        editor = false;
        memtest86.enable = cfg.memtest;
        netbootxyz.enable = cfg.netboot;
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

    boot.lanzaboote = mkIf cfg.secureBoot {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };

    environment.systemPackages = mkIf cfg.secureBoot [
      pkgs.sbctl
    ];

    security.pam.loginLimits = [
      { domain = "*"; item = "nofile"; type = "-"; value = "32768"; }
      { domain = "*"; item = "memlock"; type = "-"; value = "32768";}
    ];
  };
}
