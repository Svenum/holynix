{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.systemType.desktop;
in
{
  options.holynix.systemType.desktop = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable desktop specific features";
    };
  };

  config = mkIf cfg.enable {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;
    services.scx = {
      enable = true;
      scheduler = "scx_lavd";
      extraArgs = [ "--autopower" ];
    };
  };
}
