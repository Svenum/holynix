{options, config, lib, pkgs, ...}:

with lib;
with lib.types;
let
  cfg = config.holynix.virtualisation.kvm.lookingglass;
  kvmCfg = config.holynix.virtualisation.kvm;
in
{
  options.holynix.virtualisation.kvm.lookingglass = {
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
    
    boot.extraModulePackages = with config.boot.kernelPackages; [ kvmfr ];
    boot.kernelModules = [ "kvmfr" ];

    # Lookingglass config
    environment.etc."looking-glass-client.ini" = {
      user = "root";
      group = "root";
      mode = "0755";
      text = generators.toINI {}{
        wayland = { fractionScale = "yes"; };
        opengl = { amdPinnedMem = "yes"; };
        input = {
          rawMouse = "yes";
          autoCapture = "yes";
          captureOnly = "yes";
          escapeKey = "KEY_F12";
        };
        spice = {
          enable = "yes";
          clipboard = "yes";
          audio = "yes";
        };
        app = {
          shmFile = "/dev/kvmfr0";
          allowDMA = "yes";
        };
        win = {
          alerts = "no"; 
        };
      };
    };
  };
}
