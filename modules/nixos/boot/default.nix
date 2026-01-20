{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

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
    uefi-shell = mkOption {
      type = bool;
      default = false;
      description = "enable edk2-uefi-shell";
    };
  };

  config = mkIf cfg.enable {

    boot = {
      # Filesystems
      supportedFilesystems = [ "ntfs" ];

      # Kernel
      kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;

      # Bootloader
      loader = {
        systemd-boot = mkIf cfg.systemdBoot {
          enable = mkIf (!cfg.secureBoot) true;
          configurationLimit = 15;
          editor = false;
          memtest86 = {
            enable = cfg.memtest;
            sortKey = "z_memtest";
          };
          netbootxyz = {
            enable = cfg.netboot;
            sortKey = "z_netboot";
          };
          edk2-uefi-shell = {
            enable = cfg.uefi-shell;
            sortKey = "z_edk2";
          };
        };
        efi.canTouchEfiVariables = true;
        timeout = mkDefault 1;
      };

      initrd.systemd.enable = true;
      kernelParams = [
        "quiet"
        "udev.log_level=3"
      ];

      # Configure Plymouth
      plymouth.enable = true;

      lanzaboote = mkIf cfg.secureBoot {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
        inherit (config.boot.loader.systemd-boot) configurationLimit;
      };
    };

    # Firmware
    hardware.enableRedistributableFirmware = true;

    # activate tpm2
    security.tpm2.enable = true;

    environment.systemPackages = mkIf cfg.secureBoot [
      pkgs.sbctl
    ];

    security.pam.loginLimits = [
      {
        domain = "*";
        item = "nofile";
        type = "-";
        value = "32768";
      }
      {
        domain = "*";
        item = "memlock";
        type = "-";
        value = "32768";
      }
    ];
  };
}
