{
  config,
  lib,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.restic;
in
{
  options.holynix.services.restic = {
    enable = mkEnableOption "Enable restic backup for user";
  };

  config = mkIf cfg.enable {
    services.restic = {
      enable = true;
      backups.home = {
        initialize = true;
        inhibitsSleep = true;
        paths = [ config.home.homeDirectory ];
        passwordFile = "${config.home.homeDirectory}/.config/restic/pw";
        repositoryFile = "${config.home.homeDirectory}/.config/restic/repo";
        extraBackupArgs = [ "--exclude-caches" ];
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 6"
          "--keep-tag important"
        ];
        exclude = [
          # Caches
          ".cache"
          ".local/share/Trash"
          ".local/share/baloo"
          ".npm"
          ".cargo/registry"
          ".rustup/toolchains"
          ".cargo/git"

          # Gaming
          "Games"
          "**/steamapps/common"
          "**/steamapps/downloading"
          "**/steamapps/shadercache"
          "**/steamapps/temp"
          "**/steamapps/workshop"

          # Flatpak binaries/runtimes (redownloadable, keep .var/app config+data)
          ".local/share/flatpak"

          # Flatpak per-app cache only (keep config + data)
          "/home/user/.var/app/*/cache"

          # Browser profiles
          ".mozilla/firefox/*/storage"
          ".config/google-chrome/*/Service Worker"
          ".config/BraveSoftware"

          # Build artifacts / VCS noise
          "**/node_modules"
          "**/target"
          "**/__pycache__"
          "**/*.pyc"
          "**/.git"

          # Disk/VM images
          "**/*.qcow2"
          "**/*.img"
          "**/*.iso"

          # Logs
          "**/*.log"

          # Editor/IDE junk
          "**/.direnv"
          "**/result"
          "**/result-*"

          # Trash
          ".local/share/Trash"
        ];
      };
    };
  };
}
