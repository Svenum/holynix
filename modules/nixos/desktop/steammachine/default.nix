{ config, lib, pkgs, ... }:

with lib;
with lib.types;

let
  cfg = config.holynix.desktop.steammachine;
  gs-steam = pkgs.writeShellScriptBin "gs-steam" ''
    exec ${lib.getBin pkgs.gamescope}/bin/gamescope --adaptive-sync --rt --steam -- ${cfg.command} -pipewire-dmabuf -tenfoot -steamdeck -steamos3
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
  steamos-session-select = pkgs.writeShellScriptBin "steamos-session-select" ''
    #!/usr/bin/env bash 
    ${cfg.command} -shutdown
  '';
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
      default = "${lib.getBin pkgs.steam}/bin/steam";
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

    services.displayManager.sessionPackages = [
      sessionFile
    ];

    hardware.graphics = {
      # this fixes the "glXChooseVisual failed" bug, context: https://github.com/NixOS/nixpkgs/issues/47932
      enable = true;
      enable32Bit = true;
    };

    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    security.wrappers = {
      bwrap = {
        owner = "root";
        group = "root";
        source = "${pkgs.bubblewrap}/bin/bwrap";
        setuid = true;
      };
    };

    environment.systemPackages = with pkgs; [
      gs-steam
      steamos-session-select
    ] ++ optional cfg.installSteam pkgs.steam;
  };

}
