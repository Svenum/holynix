{ options, config, pkgs, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.printer;

  mkPrinterConfig = props: {
    inherit (props) name;
    inherit (props) deviceUri;
    inherit (props) description;
    inherit (props) model;
  };
in
{
  options.holynix.printer = {
    enable = mkOption {
      type = bool;
      default = false;
    };
    discovery = mkOption {
      type = bool;
      default = false;
    };
    defaultPrinter = mkOption {
      type = nullOr (str);
      default = null;
    };
    printers = mkOption {
      default = { };
      type = listOf (submodule (
        { options, ... }:
        {
          options = {
            name = mkOption {
              type = str;
              default = "";
            };
            deviceUri = mkOption {
              type = str;
              default = "";
            };
            model = mkOption {
              type = str;
              default = "";
            };
            description = mkOption {
              type = nullOr (str);
              default = null;
            };
          };
        }
      ));
    };
  };

  config = mkIf cfg.enable {
    # Enable printer
    services.printing = {
      enable = true;
      drivers = with pkgs; [ epson-escpr2 epson-escpr hplip ];
    };
    # Enable auto discovery
    services.avahi.enable = mkDefault cfg.discovery;
    services.avahi.nssmdns4 = cfg.discovery;
    services.avahi.openFirewall = cfg.discovery;

    hardware.printers = mkIf (cfg.printers != { }) {
      ensurePrinters = builtins.map mkPrinterConfig cfg.printers;
      ensureDefaultPrinter = mkIf (cfg.defaultPrinter != null) cfg.defaultPrinter;
    };

    environment.systemPackages = with pkgs; [
      libinklevel
      epson-escpr
      epson-escpr2
      hplip
    ];
  };
}
