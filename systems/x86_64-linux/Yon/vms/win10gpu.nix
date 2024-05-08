{ nvram_path, pkgs, uuid }:

let
  vmConf = import ./win10.nix { inherit nvram_path; inherit pkgs; inherit uuid; };
in
vmConf // {
  name = "Windows GPU Nix";
  uuid = uuid;
  description = "A Windows 10 vm define in nix with gpu passthrough";

  vcpu = vmConf.vcpu // { count = 12; };
  memory = vmConf.memory // { count = 20; };
  cputune = {
    vcpupin = vmConf.cputune.vcpupin ++ [
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
  cpu = vmConf.cpu // {
    topology = vmConf.cpu.topology // {
      cores = 6;
    };
  };

  devices = vmConf.devices // {
    # GPU passthrough
    video = {
      model = {
        type = "none";
      };
    };

    hostdev = vmConf.devices.hostdev ++ [
      {
        mode = "subsystem";
        type = "pci";
        managed = true;
        source.address = {
          domain = 0;
          bus = 3;
          slot = 0;
          function = 0;
        };
      }
      {
        mode = "subsystem";
        type = "pci";
        managed = true;
        source.address = {
          domain = 0;
          bus = 3;
          slot = 0;
          function = 1;
        };
      }
    ];
  };
}
