{ config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.steammachine;
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

    systemd.services."steammachine-getty" = {
      description = "Getty for tty9 for the steammachine";
      wantedBy = [ "getty.target" ];
      after = [ "systemd-user-sessions.service" ];
      serviceConfig = {
        ExecStart = [ "/sbin/agetty --autologin steam --noclear tty9 linux" ];
        Type = "idle";
        Restart = "always";
      };
    };
  };
}
