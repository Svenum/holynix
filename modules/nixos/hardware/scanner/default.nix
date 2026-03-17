{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.hardware.scanner;
in
{
  options.holynix.hardware.scanner = {
    enable = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    hardware.sane = {
      enable = true;
      extraBackends = with pkgs; [
        sane-airscan
        hplipWithPlugin
        epkowa
      ];
    };

    # Enable usb scanner support
    services.ipp-usb.enable = true;
  };
}
