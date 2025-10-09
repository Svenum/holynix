{ config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.steammachine;
  gs = pkgs.writeScriptBin "gs.sh" ''
    #!/usr/bin/env bash
    exec gamescope --adaptive-sync --hdr-enabled --rt --steam -- flatpak run com.valvesoftware.Steam -pipewire-dmabuf -tenfoot -bigpicture
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
  };

  config = mkIf cfg.enable {
    holynix.users."steam" = {
      isGuiUser = false;
      isSudoUser = false;
      isKvmUser = false;
    };

    environment = {
      loginShellInit = ''
        [[ "$(tty)" = "/dev/tty9" ]] && ${gs}/bin/gs.sh
      '';
      systemPackages = with pkgs; [
        gamescope-wsi
      ];
    };

    systemd.services."steammachine-getty" = {
      description = "Getty for tty9 for the steammachine";
      wantedBy = [ "getty.target" ];
      after = [ "systemd-user-sessions.service" ];
      serviceConfig = {
        ExecStart = [ "${pkgs.util-linux}/bin/agetty --autologin steam --noclear tty9 linux" ];
        Type = "idle";
        Restart = "always";
      };
    };
  };
}
