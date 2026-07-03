{
  config,
  lib,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.jellyfin;
  cfgC = config.holynix.services.cloudflared;
  cfgS = config.holynix.services;
in
{

  options.holynix.services.jellyfin = {
    enable = mkEnableOption "Enable JellyFin";
    gpuType = mkOption {
      type = enum [
        "none"
        "amf"
        "qsv"
        "nvenc"
        "v4l2m2m"
        "vaapi"
      ];
      default = "nvenc";
      description = ''
        The type of hardware acceleration for JellyFin
      '';
    };
  };

  config = mkIf cfg.enable {
    services = {
      cloudflared.tunnels."${cfgC.tunnelId}".ingress."jellyfin.${cfgS.publicDomain}" =
        mkIf cfgC.enable "https://jellyfin.${cfgS.privateDomain}";
      jellyfin = {
        enable = true;
        hardwareAcceleration = {
          device = "/dev/dri/renderD128";
          enable = true;
          type = cfg.gpuType;
        };
        transcoding = {
          enableHardwareEncoding = true;
          hardwareDecodingCodecs = {
            h264 = true;
            hevc = true;
            vc1 = true;
            hevc10bit = true;
            mpeg2 = true;
          };
          hardwareEncodingCodecs = {
            hevc = true;
          };
        };
      };
      caddy = {
        enable = true;
        virtualHosts."jellyfin.${cfgS.publicDomain}" = {
          serverAliases = [ "jellyfin.${cfgS.privateDomain}" ];
          extraConfig = ''
            reverse_proxy http://127.0.0.1:8096
          '';
        };
      };
    };
    systemd.services.jellyfin.serviceConfig.DeviceAllow = [
      "/dev/dri/renderD128 rw"
      "char-nvidia rw"
      "/dev/nvidiactl rw"
      "/dev/nvidia-uvm rw"
      "/dev/nvidia-uvm-tools rw"
    ];
    networking.firewall = {
      allowedUDPPorts = [
        1900
        7359
      ];
    };
  };
}
