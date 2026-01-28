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
  podmanCfg = config.holynix.virtualisation.podman;

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
          EnvironmentFile = mkIf (attrs.envFile != null) attrs.envFile;
          WorkingDirectory = mkIf attrs.rootless cfg.dataDir;
          Type = "simple";
          User = mkIf attrs.rootless cfg.uid;
          ExecStartPre = mkIf attrs.autoUpdate "${lib.getExe pkgs.podman-compose} -p ${attrs.name} -f ${composePath} pull";
          ExecStart = "${lib.getExe pkgs.podman-compose} -p ${attrs.name} -f ${composePath} up";
          ExecStop = "${lib.getExe pkgs.podman-compose} -p ${attrs.name} -f ${composePath} down";
        };
        unitConfig = {
          StartLimitInterval = 10;
          After = mkIf attrs.rootless [
            "user@${toString cfg.uid}.service"
            "linger-users.service"
          ];
          Wants = mkIf attrs.rootless [ "linger-users.service" ];
          Requires = mkIf attrs.rootless [
            "user@${toString cfg.uid}.service"
          ];
        };
        restartIfChanged = true;
      };
    };

  mkBridge = attrs: {
    ${attrs.name} = {
      autoStart = true;
      networkConfig = {
        driver = "ipvlan";
        gateways = [ attrs.address ];
        subnets = [ "${attrs.subnet}/${toString attrs.prefixLength}" ];
        options.parent = attrs.name;
      };
    };
  };
in
{
  options.holynix.services.compose = {
    enable = mkEnableOption "Enable compose Services";
    user = mkOption {
      type = nullOr str;
      default = "compose";
      description = "name of the user if stack is rootless";
    };
    uid = mkOption {
      type = nullOr int;
      default = 123;
      description = "ID under whicht the compose services should run if is rootless";
    };
    dataDir = mkOption {
      type = nullOr str;
      default = "/var/lib/compose";
      description = "Direcotry for the compose user if stack is rootless";
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
            envFile = mkOption {
              type = nullOr str;
              default = null;
              description = "Path to env File used for secrets";
            };
            rootless = mkOption {
              type = bool;
              default = false;
              description = "run stack rootless";
            };
          };
        })
      );
    };
  };

  config = mkIf cfg.enable {
    holynix.virtualisation.podman.enable = true;

    virtualisation.quadlet = {
      networks = mkIf (podmanCfg.bridges != null) (
        foldl (acc: x: acc // mkBridge x) { } podmanCfg.bridges
      );
    };

    systemd.services = foldl (acc: x: acc // mkService x) { } cfg.stacks;
    users.users = mkIf (cfg.user != null) {
      ${cfg.user} = {
        isSystemUser = true;
        inherit (cfg) uid;
        group = cfg.user;
        linger = true;
        autoSubUidGidRange = true;
        home = cfg.dataDir;
        createHome = true;
      };
    };

    users.groups.${cfg.user} = { };
  };
}
