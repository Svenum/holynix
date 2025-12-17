{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.types;

let
  inherit (inputs) nixVirt;
  cfg = config.holynix.virtualisation.kvm.virtmanager;
  kvmCfg = config.holynix.virtualisation.kvm;
  usersCfg = config.holynix.users;

  # Add connections for users;
  mkUserConfig = _name: user: {
    dconf.settings = lib.mkIf user.isKvmUser or false {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" "qemu:///session" ];
        uris = [ "qemu:///system" "qemu:///session" ];
      };
    };

    imports = if user.isKvmUser or false then [ nixVirt.homeModules.default ] else [ ];
  };

  # Add user to needed group
  mkUser = _name: user: {
    extraGroups = lib.mkIf user.isKvmUser or false [
      "kvm"
      "libvirtd"
    ];
  };
in
{
  options.holynix.virtualisation.kvm.virtmanager = {
    enable = mkOption {
      type = bool;
      default = kvmCfg.enable;
    };

  };

  config = mkIf cfg.enable {
    # Enable spiceUSBRedirection
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu.swtpm.enable = true;
      };
      spiceUSBRedirection.enable = true;
    };

    networking = {
      firewall = {
        interfaces."virbr0" = {
          allowedUDPPorts = [ 53 67 68 ];
          allowedTCPPorts = [ 53 ];
        };
        trustedInterfaces = [
          "virbr0"
          "virbr1"
        ];
      };
      nat = {
        enable = true;
        internalInterfaces = [
          "virbr0"
          "virbr1"
        ];
      };
    };

    programs.virt-manager.enable = true;

    # Add user to groups
    users.users = lib.mapAttrs mkUser usersCfg;

    # Connect to QEMU
    home-manager.users = lib.mapAttrs mkUserConfig usersCfg;

    # install package virtdeclare
    environment.systemPackages = with pkgs; [
      inputs.nixVirt.packages.x86_64-linux.default
      swtpm
    ];
  };
}
