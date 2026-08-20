{
  pkgs,
  zvolPath,
  nvramPath,
}:
{
  uuid = "359723e0-d060-4cea-9c60-74e96a113354";
  type = "kvm";

  title = "Bennos Backup";
  name = "benno_backup";

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
    check = "none";
    migratable = true;
  };

  os = {
    type = "hvm";
    arch = "x86_64";
    machine = "pc-q35-11.0";
    loader = {
      readonly = true;
      type = "pflash";
      format = "raw";
      path = "${pkgs.OVMF.fd}/FV/OVMF_CODE.fd";
    };
    nvram = {
      template = "${pkgs.OVMF.fd}/FV/OVMF_VARS.fd";
      path = "${nvramPath}/hikae_VARS.fd";
    };
  };

  features = {
    acpi = { };
    apic = { };
    vmport.state = false;
    smm.state = true;
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
    ];
  };

  on_poweroff = "destroy";
  on_reboot = "restart";
  on_crash = "destroy";

  pm = {
    suspend-to-mem.enabled = false;
    suspend-to-disk.enabled = false;
  };

  devices = {
    emulator = "${pkgs.qemu}/bin/qemu-system-x86_64";

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
        source.dev = "${zvolPath}/benno_backup/root";
        target = {
          dev = "vda";
          bus = "virtio";
        };
        boot.order = 1;
      }
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
        source.dev = "${zvolPath}/benno_backup/data";
        target = {
          dev = "vdb";
          bus = "virtio";
        };
      }
    ];

    controller = [
      {
        type = "usb";
        model = "qemu-xhci";
        ports = 15;
      }
      {
        type = "pci";
        model = "pcie-root";
      }
      {
        type = "scsi";
        model = "virtio-scsi";
      }
      {
        type = "sata";
      }
    ];

    interfaces = [
      {
        type = "bridge";
        mac.address = "52:54:00:ba:80:b8";
        source.bridge = "br0";
        model.type = "virtio";
      }
    ];

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

    channel = [
      {
        type = "unix";
        target = {
          type = "virtio";
          name = "org.qemu.guest_agent.0";
        };
      }
      {
        type = "spicevmc";
        target = {
          type = "virtio";
          name = "com.redhat.spice.0";
        };
      }
    ];

    input = [
      {
        type = "tablet";
        bus = "usb";
      }
      {
        type = "mouse";
        bus = "ps2";
      }
      {
        type = "keyboard";
        bus = "ps2";
      }
    ];

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

    sound.model = "ich9";

    video = {
      model = {
        type = "virtio";
      };
    };

    redirdev = [
      {
        bus = "usb";
        type = "spicevmc";
      }
      {
        bus = "usb";
        type = "spicevmc";
      }
    ];

    tpm = {
      model = "tpm-crb";
      backend = {
        type = "emulator";
        version = "2.0";
      };
    };

    watchdog = {
      model = "itco";
      action = "reset";
    };

    memballoon.model = "virtio";

    rng = {
      model = "virtio";
      backend = {
        model = "random";
        source = "/dev/urandom";
      };
    };
  };
}
