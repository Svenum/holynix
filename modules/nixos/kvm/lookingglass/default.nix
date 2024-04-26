{options, config, lib, pkgs, ...}:

with lib;
with lib.types;
let
  cfg = config.holynix.kvm.lookingglass;
  kvmCfg = config.holynix.kvm;
in
{
  options.holynix.kvm.lookingglass = {
    enable = mkOption {
      type = bool;
      default = kvmCfg.vfioPCIDevices != null;
    };
  };

  config = mkIf cfg.enable {
    # install looking-glass-client
    environment.systemPackages = with pkgs; [
      looking-glass-client
    ];

    # Prepare kvmfr
    services.udev.extraRules = ''
      SUBSYSTEM=="kvmfr", OWNER="root", GROUP="kvm", MODE="0660"
    '';

    boot.extraModprobeConfig = ''
      options kvmfr static_size_mb=128
    '';

    virtualisation.libvirtd.qemu.verbatimConfig = ''
      namespaces = []
      cgroup_device_acl = [
        "/dev/kvmfr0", "/dev/ptmx", "/dev/null",
        "/dev/kvm"
      ]
    '';
    
    boot.extraModulePackages = with config.boot.kernelPackages; [ holynix.kvmfr ];
    boot.kernelModules = [ "kvmfr" ];
  };
}
