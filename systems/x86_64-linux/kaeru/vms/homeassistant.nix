{
  pkgs,
  zvolPath,
  nvramPath,
}:
{
  type = "kvm";
  uuid = "76160ae2-57a0-70a8-d82c-b59350a7dca6";
  # VM Infos
  title = "Home Assistant";
  name = "homeassistant";
  # CPU and Memory
  vcpu = {
    count = 2;
    placement = "static";
  };
  memory = {
    count = 6;
    unit = "GiB";
  };
  cpu = {
    mode = "host-passthrough";
    migratable = true;
  };
  cputune.vcpupin = [
    {
      vcpu = 0;
      cpuset = "0";
    }
    {
      vcpu = 1;
      cpuset = "1";
    }
    {
      vcpu = 2;
      cpuset = "2";
    }
    {
      vcpu = 3;
      cpuset = "3";
    }
  ];
  # OS
  os = {
    type = "hvm";
    arch = "x86_64";
    machine = "pc-q35-8.0";
    loader = {
      readonly = true;
      type = "pflash";
      path = "${pkgs.OVMF.fd}/FV/OVMF_CODE.fd";
      format = "raw";
    };
    nvram = {
      template = "${pkgs.OVMF.fd}/FV/OVMF_VARS.fd";
      path = "${nvramPath}/homeassistant.nvram";
    };
  };
  features = {
    acpi = { };
    apic = { };
  };
  clock = {
    offset = "utc";
    timer = [
      {
        name = "rtc";
        tickpolicy = "catchup";
      }
      {
        name = "pit";
        tickpolicy = "delay";
      }
      {
        name = "hpet";
        present = false;
      }
      {
        name = "hypervclock";
        present = false;
      }
    ];
  };
  # Powermanagement
  on_poweroff = "destroy";
  on_reboot = "restart";
  on_crash = "restart";
  # Devices
  devices = {
    emulator = "${pkgs.qemu}/bin/qemu-system-x86_64";
    # Disks
    disk = [
      {
        type = "block";
        device = "disk";
        driver = {
          name = "qemu";
          type = "raw";
          cache = "directsync";
          discard = "unmap";
          io = "native";
        };
        source.dev = "${zvolPath}/homeassistant";
        target = {
          dev = "vda";
          bus = "virtio";
        };
      }
    ];
    # Controllers
    controller = [
      {
        type = "usb";
        index = 0;
        model = "ich9-ehci1";
      }
      {
        type = "pci";
        index = 0;
        model = "pcie-root";
      }
      {
        type = "sata";
        index = 0;
      }
    ];
    # Network Interfaces
    interface = [
      {
        type = "bridge";
        mac.address = "52:54:00:ba:80:b7";
        source.bridge = "br0";
        model.type = "virtio";
      }
      {
        type = "bridge";
        mac.address = "52:54:00:01:a3:77";
        source.bridge = "br0.180";
        model.type = "virtio";
      }
    ];
    # Serial / Console
    serial = [
      {
        type = "pty";
        target = {
          type = "isa-serial";
          port = 0;
          model.name = "isa-serial";
        };
      }
    ];
    console = [
      {
        type = "pty";
        target = {
          type = "serial";
          port = 0;
        };
      }
    ];
    # Inputs
    input = [
      {
        type = "mouse";
        bus = "ps2";
      }
      {
        type = "keyboard";
        bus = "ps2";
      }
    ];
    channel = [
      {
        type = "unix";
        source.mode = "bind";
        target = {
          type = "virtio";
          name = "org.qemu.guest_agent.0";
        };
      }
    ];
    # Video + Audio
    sound.model = "ich9";

    graphics = {
      type = "spice";
      autoport = true;
      listen = {
        type = "address";
      };
      image = {
        compression = false;
      };
    };

    video = {
      model = {
        type = "virtio";
      };
    };
    watchdog = {
      model = "itco";
      action = "reset";
    };
    memballoon.model = "virtio";
  };
}
