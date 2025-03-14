{ options, config, lib, pkgs, ... }:

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

    # Prepare kvmfr
    services.udev.extraRules = ''
      SUBSYSTEM=="kvmfr", OWNER="root", GROUP="kvm", MODE="0660"
    '';

    boot = {
      extraModprobeConfig = ''
        options kvmfr static_size_mb=128
      '';

      extraModulePackages = with config.boot.kernelPackages; [ kvmfr ];
      kernelModules = [ "kvmfr" ];
    };

    virtualisation.libvirtd.qemu.verbatimConfig = ''
      namespaces = []
      cgroup_device_acl = [
        "/dev/kvmfr0", "/dev/ptmx", "/dev/null",
        "/dev/kvm"
      ]
    '';

    environment = {
      # install looking-glass-client
      systemPackages = with pkgs; [
        looking-glass-client
      ];

      # Lookingglass config
      etc."looking-glass-client.ini" = {
        user = "root";
        group = "root";
        mode = "0755";
        text = generators.toINI { } {
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
  };
}
