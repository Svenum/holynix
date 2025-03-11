{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Fix Wlan after suspend or Hibernate
  environment.etc."systemd/system-sleep/fix-wifi.sh".source =
    pkgs.writeShellScript "fix-wifi.sh" ''
      case $1/$2 in
        pre/*)
          ${pkgs.kmod}/bin/modprobe -r mt7921e mt792x_lib mt76
          echo 1 > /sys/bus/pci/devices/0000:04:00.0/remove
          ;;

        post/*)
          ${pkgs.kmod}/bin/modprobe mt7921e
          echo 1 > /sys/bus/pci/rescan
          ;;
      esac
    '';

  # Add AMD CPU driver
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot = {
    initrd= {
      availableKernelModules = [
        "xhci_pci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "thunderbolt"
      ];
    };
    kernelModules = [ "sg" ];
    kernelParams = [
      "mem_sleep_default=deep"
      "amd_pstate=passive"
    ];
  };

  # Configure Filesystem
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/0abec576-e226-4276-8e4f-deabb395bf65";
      fsType = "ext4";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/59dfb4d5-9964-4797-84a1-342adc189e94";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/142B-16BD";
      fsType = "vfat";
    };
    swapDevices = [
      {
        label = "Swap";
      }
    ];

    hardware = {
      # disable framework kernel module
      # https://github.com/NixOS/nixos-hardware/issues/1330
      framework.enableKmod = false;
    };

    # disable Wakup on Keyboard
    
    services.udev.extraRules = ''
      # Framework Laptop 16 Keyboard
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0018", ATTR{power/wakeup}="disabled"

      # Framework Laptop 16 Numpad Module
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0014", ATTR{power/wakeup}="disabled"
    '';

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
