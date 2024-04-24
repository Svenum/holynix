{ options, config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.locale;
  desktopCfg = config.holynix.desktop;

  singleLocale = [ "de_DE" "en_US" ];
in
{
  options.holynix.locale = mkOption {
    type = enum [ "de_DE" "en_DE" "en_US" ];
    default = "de_DE";
  };

  config = {
    i18n = {
      supportedLocales = [
        "C.UTF-8/UTF-8"
      ]
      ++ lists.optional (builtins.elem cfg singleLocale) "${cfg}.UTF-8/UTF-8"
      ++ lists.optionals (cfg == "en_DE") [ "en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" ];

      defaultLocale = if (builtins.elem cfg singleLocale) then
        "${cfg}.UTF-8/UTF-8"
      else if (cfg == "en_DE") then
        "en_US.UTF-8"
      else
        ""
      ;

      extraLocaleSettings = if (builtins.elem cfg singleLocale) then 
        { LC_ALL = "${cfg}.UTF-8"; }
      else if (cfg == "en_DE") then
        {
          LC_ADDRESS = "de_DE.UTF-8";
          LC_IDENTIFICATION = "de_DE.UTF-8";
          LC_MEASUREMENT = "de_DE.UTF-8";
          LC_MONETRAY = "de_DE.UTF-8";
          LC_NAME = "de_DE.UTF-8";
          LC_NUMERIC = "de_DE.UTF-8";
          LC_PAPER = "de_DE.UTF-8";
          LC_TELEPHONE = "de_DE.UTF-8";
          LC_TIME = "de_DE.UTF-8";
        }
      else
        {};
    };
    
    services.xserver.xkb = mkIf desktopCfg.enable {
      layout = strings.toLower (lists.last (strings.splitString "_" cfg));
      variant = "";
    };
  };
}
