{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.gpu.nvidia;
in
{
  options.holynix.gpu.nvidia = {
    enable = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # Load kernel Modules
    services.xserver.videoDrivers = [ "nvidia" ];

    # Configure nvidia driver
    hardware = {
      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          vaapiVdpau
          libvdpau-va-gl
        ];
        extraPackages32 = with pkgs.pkgsi686Linux; [
          vaapiVdpau
        ];
      };
      nvidia = {
        modesetting.enable = true;
      };
    };

    # Install ToggleScript
    environment.systemPackages = with pkgs; [ nvtopPackages.full ];
  };
}
