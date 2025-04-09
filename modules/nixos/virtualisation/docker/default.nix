{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.virtualisation.docker;
  cfgSystemType = config.holynix.systemType;

  customPython = pkgs.python3.withPackages (pythonPkgs: [
    pythonPkgs.pyyaml
    pythonPkgs.requests
  ]);
in
{
  options.holynix.virtualisation.docker = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable docker";
    };
    defaultAddressPool = {
      base = mkOption {
        type = str;
        default = "10.10.0.0/16";
        description = "Subnet for default pool";
      };
      size = mkOption {
        type = int;
        default = 24;
        description = "Size of default docker networks";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      daemon.settings = {
        default-address-pools = [
          {
            inherit (cfg.defaultAddressPool) base;
            inherit (cfg.defaultAddressPool) size;
          }
        ];
      };
      autoPrune.enable = true;
    };

    environment.systemPackages = with pkgs; [
      docker-compose
      (mkIf cfgSystemType.server.ansibleTarget customPython)
    ];

    networking.firewall.trustedInterfaces = [ "docker0" ];
  };
}
