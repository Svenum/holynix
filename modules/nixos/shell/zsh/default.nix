{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.shell.zsh;
  themeCfg = config.holynix.theme;
  usersCfg = config.holynix.users;

  mkUserConfig = name: user: {
    home.file.".p10k.zsh".source = ./config/p10k.zsh;
    home.file.".zshrc".source = ./config/zshrc;
  };
in
{
  options.holynix.shell.zsh = {
    enable = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # Enable default settings
    holynix.shell.enable = true;

    # Set users default shell
    users.defaultUserShell = pkgs.zsh;

    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      shellInit = (builtins.readFile ./config/catppuccin_${themeCfg.flavour}-zsh-syntax-highlighting.zsh);
      promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      ohMyZsh = {
        enable = true;
        plugins = [ "git" ];
      };
    };

    # Setup zshrc and p10k
    home-manager.users = lib.mapAttrs mkUserConfig usersCfg;
  };
}
