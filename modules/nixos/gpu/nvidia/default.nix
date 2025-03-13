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
    packageChanel = mkOption {
      type = enum ["stable" "production" "beta"];
      default = "stable";
      description = "Specify the nvidia driver package channel";
    };
  };

  config = mkIf cfg.enable {
    # Load kernel Modules
    services.xserver.videoDrivers = [ "nvidia" ];

    # Configure nvidia driver
    hardware = {
      graphics = {
        enable = true;
        inherit (config.hardware.nvidia) package;
        extraPackages = with pkgs; [
          vaapiVdpau
          libvdpau-va-gl
        ];
        extraPackages32 = with pkgs.pkgsi686Linux; [
          vaapiVdpau
        ];
      };
      nvidia = {
        open = false;
        package = config.boot.kernelPackages.nvidiaPackages."${cfg.packageChanel}";
        modesetting.enable = true;
      };
    };

    # Install ToggleScript
    environment.systemPackages = with pkgs; [ nvtopPackages.full ];
  };
}
