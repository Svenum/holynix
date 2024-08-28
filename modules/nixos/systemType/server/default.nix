{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.systemType.server;

  ansible-nix-shell = pkgs.writeShellScrtipBin "ansible-nix-shell" ''
    # Initialisiere Variablen    
    p_value=""    
    r_value=""    
    collecting_p=false    
    collecting_r=false    
         
    # Durchlaufe alle Argumente    
    while [[ $# -gt 0 ]]; do    
      case "$1" in    
        -p)    
          collecting_p=true    
          collecting_r=false    
          shift    
          ;;    
        -r)    
          collecting_r=true    
          collecting_p=false    
          shift    
          ;;    
        *)    
          if $collecting_p; then    
            p_value="$p_value $1"    
          elif $collecting_r; then    
            r_value="$r_value $1"    
          fi    
          shift    
          ;;    
      esac    
    done    
         
    nix-shell -p $p_value --run "$r_value"
  '';
in
{
  options.holynix.systemType.server = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable server specific features";
    };
    ansibleTarget = mkOption {
      type = bool;
      default = false;
      description = "If true everything gets setup to be a ansible target";
    };
  };
  config = mkIf cfg.enable {
    # Node Exporter
    services.prometheus.exporters.node = {
      enable = true;
      openFirewall = true;
    };

    # SSH
    services.openssh.enable = true;

    environment.systemPackages = with pkgs; mkIf cfg.ansibleTarget [
      python3
      ansible-nix-shell
    ];
  };
}
