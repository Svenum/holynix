{ lib, config, inputs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.powerManagement;
in
{
  imports = [ inputs.auto-cpufreq.nixosModules.default ];

  options.holynix.powerManagement.enable = mkOption {
    type = bool;
    default = false;
  };

  config = mkIf cfg.enable {
    # Enable NixOS powermanagement
    powerManagement = {
      enable = true;
    };

    # Disable powerprofiles
    services.power-profiles-daemon.enable = mkForce false;

    # Disable tlp
    services.tlp.enable = mkForce false;

    # Enable auto-cpufreq
    programs.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          energy_performance_preference = "power";
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          energy_performance_preference = "balance_performance";
          governor = "performance";
          turbo = "auto";
        };
      };
    };
  };
}
