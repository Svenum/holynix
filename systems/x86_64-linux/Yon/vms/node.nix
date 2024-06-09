{ pkgs, uuid, nodeID, diskPath, nvramPath }:

{
  type = "kvm";

  # VM Infos
  title = "Node ${nodeID}";
  name = "node${nodeID}";
  uuid = uuid;
  description = "A Kubernetes node define in nix";

  # CPU and RAM
  vcpu = { count = 2; placement = "static"; };
  memory = { count = 4; unit = "GiB"; };
  cpu.node = "host-passthrough";

  # OS
  os = {
    type = "hvm";
    arch = "x86_64";
    machine = "q35";
    loader = {
      readonly = true;
      type = "pflash";
      path = "${pkgs.OVMFFull.fd}/FV/OVMF_CODE.ms.fd";
    };
    nvram = {
      template = "${pkgs.OVMFFull.fd}/FV/OVMF_VARS.ms.fd";
      path = "${nvramPath}/node${nodeID}.nvram";
    };
    boot.dev = "hd";
  };

  features = {
    acpi = {};
    apic = {};
    vmport.state = false;
  };
  
  clock = {
    offset = "localtime";
    timer = [
      { name = "rtc"; tickpolicy = "catchup"; }
      { name = "pit"; tickpolicy = "delay"; }
      { name = "hpet"; present = false; }
    ];
  };

  # PowerManagement
  pm = {
    suspend-to-mem.enabled = false;
    suspend-to-disk.enabled = false;
  };

  # Devices
  devices = {
    emulator = "${pkgs.qemu}/bin/qemu-system-x86_64";

    # Disks
    disk = [
      {
        type = "file";
        device = "disk";
        driver = {
          name = "qemu";
          type = "qcow2";
          discard = "unmap";
        };
        source.file = "${diskPath}/node${nodeID}.qcow2";
        target = {
          dev = "vda";
          bus = "virtio";
        };
      }
      {
        type = "file";
        device = "cdrom";
        target = { dev = "sda"; bus = "sata"; };
        readonly = true;
        address.type = "drive";
      }
    ];

    # Network
    interface = {
      type = "network";
      mac.address = "52:54:00:c6:2f:a${nodeID}";
      source.network = "kube";
      model.type = "virtio";
    };

    # Video + Audio
    sound.model = "ich9";

    graphics = {
      type = "spice";
      autoport = true;
      listen = { type = "address"; };
      image = { compression = false; };
    };

    video = {
      model = {
        type = "virtio";
      };
    };

    # Interfaces 
    redirdev = [
      { bus = "usb"; type = "spicevmc"; }
      { bus = "usb"; type = "spicevmc"; }
    ];

    controller = [
      { type = "usb"; model = "qemu-xhci"; ports = 15; }
      { type = "pci"; model = "pcie-root"; }
      { type = "pci"; model = "pcie-root-port"; }
    ];

    serial = [
      {
        type = "pty";
        target = { type = "isa-serial"; port = 0; model.name = "isa-serial"; };
      }
    ];

    console = [ { type = "pty"; } ];

    channel = [
      {
        type = "spicevmc";
        target = { type = "virtio"; name = "com.redhat.spice.0"; };
      }
      {
        type = "unix";
        source.mode = "bind";
        target = { type = "virtio"; name = "org.qemu.guest_agent.0"; };
      }
    ];

    # Other
    watchdog = { model = "itco"; action = "reset"; };
    memballoon.model = "virtio";

    rng = {
      model = "virtio";
      backend = {
        model = "random";
        source = /dev/urandom;
      };
    };
  };
}
