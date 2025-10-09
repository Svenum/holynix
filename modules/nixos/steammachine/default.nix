{ config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.steammachine;
  gs = pkgs.writeScriptBin "gs.sh" ''
    #!/usr/bin/env bash
    exec gamescope --adaptive-sync --hdr-enabled --rt --steam -- ${cfg.command}
  '';
in
{
  options.holynix.steammachine = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable steammachine mode on specific tty";
    };
    user = mkOption {
      type = str;
      default = "steam";
      description = "User under which steam runs";
    };
    command = mkOption {
      type = str;
      default = "steam -pipewire-dmabuf -tenfoot -bigpicture";
      description = "Set steam launch command";
    };
    installSteam = mkOption {
      type = bool;
      default = true;
      description = "Install steam";
    };
  };

  config = mkIf cfg.enable {
    holynix.users."steam" = {
      isGuiUser = false;
      isSudoUser = false;
      isKvmUser = false;
    };

    environment = {
      systemPackages = with pkgs; [
        gamescope-wsi
        gs
      ] ++ optional cfg.installSteam pkgs.steam;
    };

    systemd.services."steammachine-getty" = {
      description = "Getty for tty9 for the steammachine";
      enable = true;
      wantedBy = lib.mkForce [ ];
      after = [
        "systemd-user-sessions.service"
        "getty-pre.target"
      ] ++ optional config.boot.plymouth.enable "plymouth-quit-wait.service";
      serviceConfig = {
        ExecStart = [  " " "${pkgs.util-linux}/bin/agetty --autologin ${cfg.user} --noclear tty9 linux --login-program ${gs}/bin/gs.sh" ];
        Type = "idle";
        Restart = "always";
      };
    };
  };
}
