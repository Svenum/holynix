{ options, lib, config, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.powerManagement;
in
{
  options.holynix.powerManagement.enable = mkOption {
    type = bool;
    default = false;
  };

  config = mkIf cfg.enable {
    # Enable NixOS powermanagement + powertop
    powerManagement = {
      enable = true;
      powertop.enable = true;
    };

    # Disable powerpfiles
    services.power-profiles-daemon.enable = true;

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
