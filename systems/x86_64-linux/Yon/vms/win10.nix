{ nvram_path, pkgs, uuid }:

{
  type = "kvm";
  # VM Infos
  name = "Windows Nix";
  uuid = uuid;
  description = "A Windows 10 vm define in nix";

  sysinfo = {
    type = "smbios";
    bios.entry = [
      { name = "vendor"; value = "INSYDE Corp."; }
      { name = "version"; value = "03.02"; }
      { name = "date"; value = "01/23/2024"; }
    ];
    system.entry = [
      { name = "manufacturer"; value = "Framework"; }
      { name = "product"; value = "Laptop 16 (AMD Ryzen 7040 Series)"; }
      { name = "version"; value = "AG"; }
      { name = "serial"; value = "FRAGADDPAG4096006K"; }
      { name = "uuid"; value = uuid; }
      { name = "sku"; value = "FRAGACCP0G"; }
      { name = "family"; value = "16in"; }
    ];
  };
  
  # CPU and RAM
  vcpu = { count = 12; placement = "static"; };
  memory = { count = 20; unit = "GiB"; };
  cputune = {
    vcpupin = [
      {vcpu = 0; cpuset = "4";}
      {vcpu = 1; cpuset = "5";}
      {vcpu = 2; cpuset = "6";}
      {vcpu = 3; cpuset = "7";}
      {vcpu = 4; cpuset = "8";}
      {vcpu = 5; cpuset = "9";}
      {vcpu = 6; cpuset = "10";}
      {vcpu = 7; cpuset = "11";}
      {vcpu = 8; cpuset = "12";}
      {vcpu = 9; cpuset = "13";}
      {vcpu = 10; cpuset = "14";}
      {vcpu = 11; cpuset = "15";}
    ];
  };
  cpu = {
    mode = "host-passthrough";
    check = "none";
    migratable = true;
    cache = { level = 3; mode = "emulate"; };
    feature = [
      { policy = "disable"; name = "hypervisor"; }
      { policy = "require"; name = "svm"; }
      { policy = "require"; name = "topoext"; }
    ];
    topology = {
      sockets = 1;
      dies = 1;
      cores = 6;
      threads = 2;
    };
  };

  # OS
  os = {
    type = "hvm";
    arch = "x86_64";
    machine = "pc-q35-8.2";
    loader = {
      readonly = true;
      type = "pflash";
      path = "${pkgs.OVMFFull.fd}/FV/OVMF_CODE.ms.fd";
    };
    nvram = {
      template = "${pkgs.OVMFFull.fd}/FV/OVMF_VARS.ms.fd";
      path = "${nvram_path}/win10gpu.nvram";
    };
    smbios.mode = "sysinfo";
  };

  features = {
    acpi = {};
    apic = {};
    hyperv = {
      mode = "custom";
      relaxed = { state = true; };
      vapic = { state = true; };
      spinlocks = { state = true; retries = 8191; };
      vendor_id = { state = true; value = "1234567890ab"; };
    };
    kvm.hidden = { state = true; };
    vmport.state = false;
  };
  
  clock = {
    offset = "localtime";
    timer = [
      { name = "rtc"; tickpolicy = "catchup"; }
      { name = "pit"; tickpolicy = "delay"; }
      { name = "hpet"; present = false; }
      { name = "hypervclock"; present = true; }
    ];
  };

  # PowerManagement
  pm = {
    suspend-to-mem = { enabled = false; };
    suspend-to-disk = { enabled = false; };
  };

  # Devices
  devices = {
    emulator = "${pkgs.qemu}/bin/qemu-system-x86_64";

    # Disks
    hostdev = [
      {
        mode = "subsystem";
        type = "pci";
        managed = true;
        source.address = {
          domain = 0;
          bus = 4;
          slot = 0;
          function = 0;
        };
        boot.order = 1;
      }
    ];

    # Network
    interface = {
      type = "network";
      mac.address = "52:54:00:04:63:98";
      source.network = "default";
      model.type = "e1000e";
    };

    # Input
    input = [
      { type = "keyboard"; bus = "virtio"; }
      { type = "mouse"; bus = "virtio"; }
    ];

    # Video + Audio
    graphics = {
      type = "spice";
      autoport = true;
      listen = { type = "address"; };
      image = { compression = false; };
    };

    video = {
      model = {
        type = "vga";
        vram = 65536;
        heads  = 1;
        primary = true;
      };
    };

    sound = { model = "ich9"; };
    audio = { id = 1; type = "spice"; };

    # Interfaces 
    controller = [
      { type = "usb"; index = 0; model = "qemu-xhci"; ports = 15; }
      { type = "pci"; index = 0; model = "pcie-root"; }
      { type = "virtio-serial"; index = 0; }
    ];

    serial = [
      {
        type = "pty";
        target = { type = "isa-serial"; port = 0; model.name = "isa-serial"; };
      }
    ];

    console = [
      {
        type = "pty";
        target = { type = "serial"; port = 0; };
      }
    ];

    channel = [
      {
        type = "spicevmc";
        target = { type = "virtio"; name = "com.redhat.spice.0"; };
      }
    ];

    # Other
    watchdog = { model = "itco"; action = "reset"; };
    memballoon.model = "none";
  };

  qemu-commandline = {
    arg = [
      { value = "-cpu"; }
      { value = "host,kvm=off,hv_time,hv_vendor_id=null,-hypervisor"; }
      { value = "-machine"; }
      { value = "q35"; }
      { value = "-device"; }
      { value = "{\"driver\":\"ivshmem-plain\",\"id\":\"shmem0\",\"memdev\":\"looking-glass\"}"; }
      { value = "-object"; }
      { value = "{\"qom-type\":\"memory-backend-file\",\"id\":\"looking-glass\",\"mem-path\":\"/dev/kvmfr0\",\"size\":134217728,\"share\":true}"; }
    ];
  };
}
