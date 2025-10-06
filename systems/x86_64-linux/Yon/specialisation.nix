{ pkgs, lib, ... }:

let
  gs = pkgs.writeScriptBin "gs.sh" (builtins.readFile ./gs.sh);
in
{
  specialisation.steam.configuration = {
    services.getty.autologinUser = "steam";
    services.displayManager.sddm.enable = lib.mkForce false;
    programs = {
      gamescope = {
        enable = true;
        capSysNice = true;
      };
    };
    environment = {
      loginShellInit = ''
        [[ "$(tty)" = "/dev/tty1" ]] && ${gs}/bin/gs.sh
      '';
    };
  };
}
