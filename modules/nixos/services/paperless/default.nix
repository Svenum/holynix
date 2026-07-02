{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.paperless;
  cfgS = config.holynix.services;
in
{
  options.holynix.services.paperless = {
    enable = mkEnableOption "Enable Paperless service";
    enableOidc = mkOption {
      type = bool;
      default = false;
      description = "Enable oidc for paperless";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "services/paperless/oidc" = mkIf cfg.enableOidc { };
      "services/paperless/admin_pass" = { };
    };

    services = {
      paperless = {
        enable = true;
        configureTika = true;
        database.createLocally = true;
        environmentFile = mkIf cfg.enableOidc config.sops.secrets."services/paperless/oidc".path;
        passwordFile = config.sops.secrets."services/paperless/admin_pass".path;
        domain = "paperless.${cfgS.publicDomain}";
        settings = {
          # OCR
          PAPERLESS_OCR_LANGUAGE = "deu+eng";

          # Access
          PAPERLESS_ALLOWED_HOSTS = "paperless.${cfgS.publicDomain},paperless.${cfgS.privateDomain}";
          PAPERLESS_CSRF_TRUSTED_ORIGINS = "https://paperless.${cfgS.publicDomain},https://paperless.${cfgS.privateDomain}";
          PAPERLESS_CORS_ALLOWED_HOSTS = "https://paperless.${cfgS.publicDomain},https://paperless.${cfgS.privateDomain}";

          # Filestructure
          PAPERLESS_FILENAME_FORMAT = "{{owner_username}}/{{correspondent}}/{{created_year}}/{{title}}";
        };
      };

      postgresqlBackup = {
        enable = true;
        databases = [
          "paperless"
        ];
      };

      caddy = {
        enable = true;
        virtualHosts."paperless.${cfgS.publicDomain}" = {
          serverAliases = [ "paperless.${cfgS.privateDomain}" ];
          extraConfig = ''
            reverse_proxy localhost:${toString config.services.paperless.port}
          '';
        };
      };
    };

    # Protonmail
    systemd.services.protonmail-bridge = {
      description = "ProtonMail Bridge";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      environment.HOME = "/var/lib/protonmail-bridge";

      serviceConfig = {
        Type = "simple";

        DynamicUser = true;

        ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --noninteractive --log-level info";
        Restart = "on-failure";
        RestartSec = 5;

        StateDirectory = "protonmail-bridge";
        StateDirectoryMode = "0700";

        # Hardening
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RemoveIPC = true;
        UMask = "0077";

        CapabilityBoundingSet = "";
        AmbientCapabilities = "";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        IPAddressAllow = [
          "localhost"
          "any"
        ];

        DeviceAllow = [ ];
      };
    };
  };
}
