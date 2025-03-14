{ pkgs, uuid, diskPath }:

{
  inherit uuid;
  type = "qemu";
  name = "mac9.2.2";
  memory = {
    count = 512;
    unit = "MiB";
  };
  vcpu = {
    placement = "static";
    count = 1;
  };
  os = {
    type = "hvm";
    arch = "ppc";
    machine = "mac99";
  };
  clock.offset = "utc";
  on_poweroff = "destroy";
  on_reboot = "restart";
  on_crash = "destroy";
  devices = {
    emulator = "${pkgs.nur.repos.Rhys-T.qemu-screamer}/bin/qemu-system-ppc"; # screamer build with audio support
    controller = [
      {
        type = "usb";
        index = 0;
        model = "piix3-uhci";
        address = {
          type = "pci";
          domain = 0;
          bus = 0;
          slot = 2;
          function = 0;
        };
      }
      {
        type = "pci";
        index = 0;
        model = "pci-root";
      }
    ];
    graphics = {
      type = "spice";
      listen = {
        type = "none";
      };
      image = {
        compression = false;
      };
      gl = {
        enable = false;
      };
    };
    video = {
      model = {
        type = "none";
      };
    };
    memballoon = {
      model = "none";
    };
  };
  qemu-commandline = {
    arg = [
      { value = "-M"; }
      { value = "mac99,usb=on"; } # won't boot without `usb=on`. libvirt don't allow removing usb controller
      { value = "-device"; }
      { value = "ide-hd,bus=ide.0,drive=Macintosh"; }
      { value = "-drive"; }
      {
        value = "if=none,format=qcow2,media=disk,id=Macintosh,file=${diskPath}/macos.qcow2,discard=unmap,detect-zeroes=unmap";
      }
      { value = "-device"; }
      { value = "ide-cd,bus=ide.0,drive=Installer"; }
      { value = "-device"; }
      { value = "sungem,mac=2A:84:84:06:3E:78,netdev=net0"; }
      { value = "-netdev"; }
      { value = "user,id=net0"; }
      { value = "-device"; }
      { value = "VGA,edid=on"; }
      { value = "-prom-env"; }
      { value = "boot-args=-v"; }
      { value = "-prom-env"; }
      { value = "vga-ndrv?=true"; }
      { value = "-prom-env"; }
      { value = "auto-boot?=true"; }
      { value = "-g"; }
      { value = "1024x768x32"; }
      { value = "-boot"; }
      { value = "c"; } # set to d when booting from iso
    ];
  };
}
