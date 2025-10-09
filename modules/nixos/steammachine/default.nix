{ config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.steammachine;
  gs = pkgs.writeScriptBin "gs.sh" ''
    #!${lib.getBin pkgs.bash}/bin/bash
    ${lib.getBin pkgs.coreutils}/bin/id
    exec ${lib.getBin pkgs.gamescope}/bin/gamescope --adaptive-sync --hdr-enabled --rt --steam -- ${cfg.command}
    ${lib.getBin pkgs.coreutils}/bin/id
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
    holynix.users."steam" = {
      isGuiUser = false;
      isSudoUser = false;
      isKvmUser = false;
    };

    environment = {
      interactiveShellInit = ''
        # Start steam if tty9
        if [ "$(tty)" = "/dev/tty9" ]; then
          ${gs}/bin/gs.sh
        fi
      '';
      systemPackages = with pkgs; [
        gamescope-wsi
        gamescope
        gs
      ] ++ optional cfg.installSteam pkgs.steam;
    };

    systemd.services."steammachine-getty" = {
      description = "Getty for tty9 for the steammachine";
      enable = true;
      wantedBy = [ "getty.target" ];
      after = [
        "systemd-user-sessions.service"
        "getty-pre.target"
      ] ++ optional config.boot.plymouth.enable "plymouth-quit-wait.service";
      serviceConfig = {
        ExecStart = [ " " "${lib.getBin pkgs.util-linux}/bin/agetty --autologin ${cfg.user} --noclear tty9 linux" ];
        Type = "idle";
        Restart = "always";
      };
    };
  };
}
