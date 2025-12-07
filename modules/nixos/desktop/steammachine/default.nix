{ config, lib, pkgs, ... }:

with lib;
with lib.types;

let
  cfg = config.holynix.desktop.steammachine;
in
{
  options.holynix.desktop.steammachine = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable steammachine UI";
    };
    enableSteamMachine = mkOption {
      type = bool;
      default = false;
      description = "Enable SteamDeck mode + install helper scripts";
    };
  };

  config = mkIf cfg.enable {
    # Enable default desktop settings
    holynix = {
      desktop.enable = true;
    };

    programs = {
      gamescope = {
        enable = true;
        capSysNice = true;
      };
      steam = {
        enable = true;
        gamescopeSession = {
          enable = true;
          steamArgs = [
            "-pipewire-dmabuf"
            "-tenfoot"
            "-steamos3"
          ] ++ optional cfg.enableSteamMachine "-steamdeck";
          args = [
            "--adaptive-sync"
            "--rt"
          ];
        };
        localNetworkGameTransfers.openFirewall = true;
        remotePlay.openFirewall = true;
      };
    };

    systemd.tmpfiles.rules = mkIf cfg.enableSteamMachine [
      "C+ /usr/bin 0775 root root - ${pkgs.holynix.steam-session-helper}/bin"
    ];

    environment.systemPackages = [
      pkgs.holynix.steam-session-helper
    ];
  };

}
