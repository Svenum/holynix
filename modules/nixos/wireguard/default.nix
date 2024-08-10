{ options, config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.wireguard;

  mkWgConfig = name: interface: {
   configFile = interface.configFile; 
  };
in
{
  options.holynix.wireguard = {
    enable = mkOption {
      type = bool;
      default = false;
    };
    interfaces = mkOption {
      type = attrsOf (submodule (
        { options, ... }:
        {
          options = {
            configFile = mkOption {
              type = nullOr (str);
              default = null;
              description = "Path to config file";
            };
          };  
        }
      ));
      default = {};
    };
  };

  config = mkIf cfg.enable {
    # Allow Wireguard
    networking.firewall = {
      enable = true;
      # if packets are still dropped, they will show up in dmesg
      logReversePathDrops = true;
      # wireguard trips rpfilter up
      extraCommands = ''
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
      '';
      extraStopCommands = ''
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
      '';
    };
    networking.wg-quick.interfaces = mapAttrs mkWgConfig cfg.interfaces;
  };
}
