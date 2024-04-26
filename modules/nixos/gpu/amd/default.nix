{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.gpu.amd;
in
{
  options.holynix.gpu.amd = {
    enable = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        amdvlk
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };

    # Enable gui software
    programs.corectrl.enable = true;

    # install needed tools
    environment.systemPackages = with pkgs; [
      clinfo
      nvtopPackages.full
    ];
  };
}
