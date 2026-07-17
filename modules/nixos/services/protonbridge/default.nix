{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.protonbridge;
  stateDir = "/var/lib/protonbridge";
in
{
  options.holynix.services.protonbridge = {
    enable = lib.mkEnableOption "ProtonMail Bridge (headless)";
  };

  config = mkIf cfg.enable {
    users.users.protonbridge = {
      isSystemUser = true;
      group = "protonbridge";
      home = stateDir;
      createHome = true;
    };

    users.groups.protonbridge = { };
    environment.systemPackages = with pkgs; [
      protonmail-bridge
      pass
      gnupg
    ];

    systemd.services = {
      protonmail-bridge-gpg-init = {
        description = "Initialize GPG key for ProtonMail Bridge pass backend";
        wantedBy = [ "multi-user.target" ];
        before = [ "protonmail-bridge.service" ];
        serviceConfig = {
          Type = "oneshot";
          User = "protonbridge";
          StateDirectory = "protonbridge";
        };

        script = ''
          set -euo pipefail
          export GNUPGHOME=${stateDir}/.gnupg

          mkdir -p "$GNUPGHOME"
          chmod 700 "$GNUPGHOME"

          if ! gpg --list-secret-keys protonbridge >/dev/null 2>&1; then
            gpg \
              --batch \
              --pinentry-mode loopback \
              --passphrase "" \
              --quick-gen-key \
              protonbridge \
              default \
              default \
              never
          fi
        '';

        path = with pkgs; [
          gnupg
        ];
      };
      protonmail-bridge = {
        description = "ProtonMail Bridge (headless)";
        after = [
          "network-online.target"
          "protonmail-bridge-gpg-init.service"
        ];
        wants = [ "network-online.target" ];

        serviceConfig = {
          User = "protonbridge";
          WorkingDirectory = stateDir;
          StateDirectory = "protonbridge";

          ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --noninteractive";

          Restart = "always";
          RestartSec = "5";

          Environment = [
            "GNUPGHOME=${stateDir}/.gnupg"
            "PASSWORD_STORE_DIR=${stateDir}/.password-store"
          ];
        };

        preStart = ''
          set -euo pipefail

          export PASSWORD_STORE_DIR=${stateDir}/.password-store
          export GNUPGHOME=${stateDir}/.gnupg

          mkdir -p "$PASSWORD_STORE_DIR"

          # Initialize pass store if not present
          if [ ! -f "$PASSWORD_STORE_DIR/.initialized" ]; then
            pass init "protonbridge"

            # marker
            touch "$PASSWORD_STORE_DIR/.initialized"
          fi
        '';

        path = with pkgs; [
          gnupg
          pass
        ];
      };
    };
  };
}
