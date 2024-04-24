{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.users;

  mkUser = name: user: {
    isNormalUser = true;
    description = name;
    shell = mkIf user.shell;
    extraGroups = [
      "networkmanager"
      "network"
      "video"
      "sys"
      "audio"
      "optical"
      "scanner"
      "lp"
      (mkIf (if builtins.hasAttr "isSudoUser" user then user.isSudoUser else false) "wheel")
    ];

    useDefaultShell = true;
    uid = mkIf (if builtins.hasAttr "uid" user then true else false) user.uid;
    openssh.authorizedKeys.keys = mkIf (if builtins.hasAttr "authorizedKeys" user then true else false) user.authorizedKeys;
  };

  mkUserConfig = name: user: {
    # Home-Manager Config
    home = {
      username = name;
      homeDirectory = "/home/${name}";
      stateVersion = "23.11";
    };
    programs.home-manager.enable = true;

    # Git Config
    programs.git = mkIf (if builtins.hasAttr "git" user then true else false) {
      enable = true;
      userName = user.git.userName;
      userEmail = user.git.userEmail;
      extraConfig = {
        safe.directory = "/etc/nixos";
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

    # Import user specific modues if needed
    imports = (if builtins.pathExists ../../users/${name}/default.nix then [ ../../users/${name} ] else []);
  };

 # hasZsh = users: 
 #   let
 #     checkUser = user: 
 #     if user.shell == pkgs.zsh then
 #       true
 #     else
 #       false;
 #   in
 #   builtins.any checkUser (builtins.attr)
in
{
  options.holynix = {
    users = mkOption {
      default = {};
      type = attrsOf (submodule (
        { name, config, options, ... }:
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
            isKvmUser = mkOption {
              type = bool;
              default = false;
            };
            shell = mkOption {
              type = nullOr (shellPackage);
              default = null;
            };
            authorizedKeys = mkOption {
              type = nullOr (str);
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

  config = mkIf (if cfg != {} then true else false) {
    # Create user
    users.users = mkMerge [ (mapAttrs mkUser cfg) { root.hashedPassword = "!"; } ];

    # Configure user
    home-manager.users = mapAttrs mkUserConfig cfg;
    home-manager.extraSpecialArgs = {
      systemConfig = config;
    };
  };
}
