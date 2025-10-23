{ config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.users;
  themeCfg = config.holynix.theme;

  mkUser = name: user: {
    isNormalUser = true;
    description = name;
    shell = mkIf (user.shell != null) user.shell;
    password = mkIf (user.password != null) user.password;
    initialPassword = mkIf (user.initialPassword != null) user.initialPassword;
    extraGroups = [
      "networkmanager"
      "network"
      "video"
      "sys"
      "audio"
      "optical"
      "scanner"
      "lp"
      "input"
      (mkIf (if builtins.hasAttr "isSudoUser" user then user.isSudoUser else false) "wheel")
      (mkIf (if builtins.hasAttr "isDockerUser" user then user.isDockerUser else false) "docker")
    ];

    inherit (user) uid;
    openssh.authorizedKeys.keys = mkIf (user.authorizedKeys != null) user.authorizedKeys;
  };

  mkUserConfig = name: user: {
    # Home-Manager Config
    home = {
      username = name;
      homeDirectory = "/home/${name}";
      inherit (config.system) stateVersion;
    };
    programs.home-manager.enable = true;

    # Git Config
    programs.git = mkIf (if builtins.hasAttr "git" user then true else false) {
      enable = true;
      settings = {
        user = {
          email = user.git.userEmail;
          name = user.git.userName;
        };
        safe.directory = "/etc/nixos";
        pager.branch = false;
      };
    };

    # XDG Config
    xdg.userDirs = mkIf (if builtins.hasAttr "isGuiUser" user then user.isGuiUser else false) {
      enable = true;
      createDirectories = true;
      extraConfig = {
        XDG_GAMES_DIR = "${config.home-manager.users.${name}.home.homeDirectory}/Games";
        XDG_GITHUB_DIR = "${config.home-manager.users.${name}.home.homeDirectory}/GitHub";
      };
    };

    catppuccin = {
      enable = true;
      inherit (themeCfg) flavor;
      inherit (themeCfg) accent;
    };

    # Import user specific modues if needed
  };
in
{
  options.holynix = {
    users = mkOption {
      default = { };
      type = attrsOf (submodule (
        { name, ... }:
        {
          options = {
            isGuiUser = mkOption {
              type = bool;
              default = false;
            };
            isSudoUser = mkOption {
              type = bool;
              default = false;
            };
            isDockerUser = mkOption {
              type = bool;
              default = false;
            };
            isKvmUser = mkOption {
              type = bool;
              default = false;
            };
            shell = mkOption {
              type = nullOr shellPackage;
              default = null;
            };
            authorizedKeys = mkOption {
              type = nullOr (listOf singleLineStr);
              default = null;
            };
            uid = mkOption {
              type = nullOr int;
              default = null;
            };
            password = mkOption {
              type = nullOr str;
              default = null;
            };
            initialPassword = mkOption {
              type = nullOr str;
              default = null;
            };
            extraGroups = mkOption {
              type = nullOr (listOf singleLineStr);
              default = null;
            };
            git = {
              userName = mkOption {
                type = str;
                default = name;
              };
              userEmail = mkOption {
                type = str;
                default = name + "@example.com";
              };
            };
          };
        }
      ));
    };
  };

  config = mkIf (if cfg != { } then true else false) {
    # Create user
    users.users = mkMerge [ (mapAttrs mkUser cfg) { root.hashedPassword = "!"; } ];

    # Configure user
    home-manager.users = mapAttrs mkUserConfig cfg;
    home-manager.extraSpecialArgs = {
      systemConfig = config;
    };
  };
}
