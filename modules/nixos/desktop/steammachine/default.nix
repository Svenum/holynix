{ config, lib, pkgs, ... }:

with lib;
with lib.types;

let
  cfg = config.holynix.desktop.steammachine;
  gs-steam = pkgs.writeShellScriptBin "steam-gs" ''
    exec ${lib.getBin pkgs.gamescope}/bin/gamescope --adaptive-sync --hdr-enabled --rt --steam -- ${cfg.command}
  '';
  sessionFile = (pkgs.writeTextDir "share/wayland-sessions/steam.desktop" ''
    [Desktop Entry]
    Name=Steam
    Comment=A digital distribution platform
    Exec=${gs-steam}/bin/gs-steam
    Type=Application
  '').overrideAttrs
    (_: {
      passthru.providedSessions = [ "steam" ];
    });
in
{
  options.holynix.desktop.steammachine = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable steammachine UI";
    };
    command = mkOption {
      type = str;
      default = "${lib.getBin pkgs.steam}/bin/steam -pipewire-dmabuf -tenfoot -bigpicture";
      description = "Set steam launch command";
    };
    installSteam = mkOption {
      type = bool;
      default = true;
      description = "Install steam";
    };
  };

  config = mkIf cfg.enable {
    # Enable default desktop settings
    holynix.desktop.enable = true;

    services.displayManager.sessionPack = [
      sessionFile
    ];

    hardware.graphics = {
      # this fixes the "glXChooseVisual failed" bug, context: https://github.com/NixOS/nixpkgs/issues/47932
      enable = true;
      enable32Bit = true;
    };

    environment.systemPackages = with pkgs; [
      gamescope-wsi
      gamescope
      gs
    ] ++ optional cfg.installSteam pkgs.steam;
  };

}
