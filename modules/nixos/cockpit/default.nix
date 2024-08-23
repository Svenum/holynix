{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.cockpit;
in
{
  options.holynix.cockpit = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable Cockpit";
    };
    package = mkOption {
      type = package;
      default = pkgs.cockpit;
      description = "Package wich is used by cockpit";
    };
  };

  config = mkIf cfg.enable {
    services.cockpit = {
      enable = true;
      openFirewall = true;
      package = cfg.package;
    };
  };
}
