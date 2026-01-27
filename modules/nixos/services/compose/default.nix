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
      "${attrs.name}-compose" = mkIf attrs.enable {
        enable = true;
        wantedBy = [ "multi-user.target" ];
        path = with pkgs; [
          podman
          podman-compose
          su
        ];
        serviceConfig = {
          Type = "simple";
          User = cfg.uid;
          ExecStartPre = mkIf attrs.autoUpdate "${lib.getExe pkgs.podman} compose -p ${attrs.name} -f ${composePath} pull";
          ExecStart = "${lib.getExe pkgs.podman} compose --all-resources -p ${attrs.name} -f ${composePath} up";
          ExecStop = "${lib.getExe pkgs.podman} compose --all-resources -p ${attrs.name} -f ${composePath} stop";
        };
        unitConfig = {
          StartLimitInterval = 10;
          After = [
            "user@${toString cfg.uid}.service"
            "linger-users.service"
          ];
          Wants = [ "linger-users.service" ];
          Requires = [
            "user@${toString cfg.uid}.service"
          ];
        };
        restartIfChanged = true;
      };
    };
in
{
  options.holynix.services.compose = {
    enable = mkEnableOption "Enable compose Services";
    uid = mkOption {
      type = int;
      default = 123;
      description = "ID under whicht the compose services should run";
    };
    dataDir = mkOption {
      type = str;
      default = "/var/lib/compose";
      description = "Direcotry for the compose";
    };
    stacks = mkOption {
      type = nullOr (
        listOf (submodule {
          options = {
            enable = mkOption {
              type = bool;
              default = true;
              description = "Enable stack";
            };
            autoUpdate = mkOption {
              type = bool;
              default = true;
              description = "Auto update images";
            };
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

    users.users.compose = {
      isSystemUser = true;
      inherit (cfg) uid;
      group = "compose";
      linger = true;
      autoSubUidGidRange = true;
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.compose = { };
  };
}
