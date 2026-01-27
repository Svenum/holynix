{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.compose;

  mkService =
    attrs:
    let
      composePath = pkgs.writeText "compose.yaml" (generators.toYAML { } attrs.composeContent);
    in
    {
      "${attrs.name}-compose" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];
        path = with pkgs; [
          podman
          podman-compose
        ];
        serviceConfig = {
          Type = "simple";
          User = config.users.users.${cfg.user}.uid;
          ExecStart = "${lib.getExe pkgs.podman-compose} -p ${attrs.name} -f ${composePath} up";
          ExecStop = "${lib.getExe pkgs.podman-compose} -p ${attrs.name} -f ${composePath} stop";
        };
        unitConfig = {
          StartLimitInterval = 10;
        };

        restartIfChanged = true;
      };
    };
in
{
  options.holynix.services.compose = {
    enable = mkEnableOption "Enable compose Services";
    user = mkOption {
      type = str;
      default = "compose";
      description = "Name under whicht the compose services should run";
    };
    stacks = mkOption {
      type = nullOr (
        listOf (submodule {
          options = {
            composeContent = mkOption {
              type = nullOr attrs;
              default = null;
              description = "Descripe compose";
            };
            name = mkOption {
              type = str;
              default = "";
              description = "Name of the stack";
            };
          };
        })
      );
    };
  };

  config = mkIf cfg.enable {
    systemd.services = foldl (acc: x: acc // mkService x) { } cfg.stacks;

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = "compose";
    };

    users.groups.compose = { };
  };
}
