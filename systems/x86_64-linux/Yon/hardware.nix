{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Add AMD CPU driver
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot = {
    initrd = {
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
      "amd_pstate=active"
    ];

    # Enable aarch64 emulation
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  # Configure Filesystem
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/0abec576-e226-4276-8e4f-deabb395bf65";
      fsType = "ext4";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/59dfb4d5-9964-4797-84a1-342adc189e94";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/142B-16BD";
      fsType = "vfat";
    };
    "/mnt/share" = {
      device = "/home/share";
      fsType = "fuse.bindfs";
      options = [
        "perms=0660:+X"
        "mirror=@users"
      ];
    };
  };
  swapDevices = [
    {
      label = "Swap";
    }
  ];

  hardware = {
    framework.enableKmod = true;

    # enable Steam input
    steam-hardware.enable = true;

    # Framework input modules
    inputmodule.enable = true;

    # enable fw-fanctrl
    fw-fanctrl = {
      enable = true;
      config = {
        defaultStrategy = "lazy";
        strategyOnDischarging = "school";
        strategies = {
          "school" = {
            fanSpeedUpdateFrequency = 5;
            movingAverageInterval = 40;
            speedCurve = [
              {
                temp = 45;
                speed = 0;
              }
              {
                temp = 55;
                speed = 15;
              }
              {
                temp = 65;
                speed = 25;
              }
              {
                temp = 70;
                speed = 35;
              }
              {
                temp = 80;
                speed = 45;
              }
              {
                temp = 90;
                speed = 50;
              }
            ];
          };
        };
      };
    };
  };

  services.udev.extraRules = ''
    # disable Wakup on Keyboard
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0018", ATTR{power/wakeup}="disabled"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0014", ATTR{power/wakeup}="disabled"

    # disable USB auto suspend for Keyboard + Numpad
    ACTION=="bind", SUBSYSTEM=="usb", ATTR{idVendor}=="32ac", ATTR{idProduct}=="0014", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="bind", SUBSYSTEM=="usb", ATTR{idVendor}=="32ac", ATTR{idProduct}=="0018", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="bind", SUBSYSTEM=="usb", ATTR{idVendor}=="2b89", ATTR{idProduct}=="0043", TEST=="power/control", ATTR{power/control}="on"
  '';

  security.pam.services.sddm.text = lib.mkForce (
    lib.strings.concatLines (
      builtins.filter (x: (lib.strings.hasPrefix "auth " x) && (!lib.strings.hasInfix "fprintd" x)) (
        lib.strings.splitString "\n" config.security.pam.services.login.text
      )
    )
    + ''
      account   include   login
      password  substack  login
      session   include   login
    ''
  );

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
