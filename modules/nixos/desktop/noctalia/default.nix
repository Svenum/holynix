{
  config,
  lib,
  ...
}:

with lib;
with lib.types;

let
  cfg = config.holynix.desktop.noctalia;
in
{
  options.holynix.desktop.noctalia = {
    enable = mkEnableOption "Enable Noctalia.";
  };

  config = mkIf cfg.enable {

    programs = {
      umbriel.enable = true;
      noctalia = {
        enable = true;
        recommendedServices.enable = true;
        systemd.enable = true;
      };
    };
  };
}
