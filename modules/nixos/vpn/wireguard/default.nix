{ config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.vpn.wireguard;

  mkWgConfig = name: interface: {
    source = interface.configFile;
    target = "NetworkManager/system-connections/${name}.nmconnection";
  };
in
{
  options.holynix.vpn.wireguard = {
    enable = mkOption {
      type = bool;
      default = false;
    };
    interfaces = mkOption {
      type = attrsOf (
        submodule (_: {
          options = {
            configFile = mkOption {
              type = nullOr str;
              default = null;
              description = "Path to config file";
            };
          };
        })
      );
      default = { };
    };
  };

  config = mkIf cfg.enable {
    # Allow Wireguard
    networking.firewall = {
      enable = true;
      # if packets are still dropped, they will show up in dmesg
      logReversePathDrops = true;
      # wireguard trips rpfilter up
      #extraCommands = ''
      #  ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
      #  ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
      #'';
      #extraStopCommands = ''
      #  ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
      #  ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
      #'';
    };
    environment.etc = mapAttrs mkWgConfig cfg.interfaces;
  };
}
