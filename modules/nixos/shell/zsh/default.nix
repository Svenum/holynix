{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.shell.zsh;
  themeCfg = config.holynix.theme;
in
{
  options.holynix.shell.zsh = {
    enable = mkOption {
      type = bool;
      default = false;
    };
    defaultShell = mkOption {
      type = bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # Enable default settings
    holynix.shell.enable = true;

    # enable as default shell
    users.defaultUserShell = mkIf cfg.defaultShell pkgs.zsh;

    # add p10k.zsh to etc
    environment.etc."zsh/p10k.zsh".source = ./config/p10k.zsh;

    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      shellInit = ''
        ${builtins.readFile ./config/catppuccin_${themeCfg.flavour}-zsh-syntax-highlighting.zsh}
        ${builtins.readFile ./config/zshrc}
      '';
      promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      ohMyZsh = {
        enable = true;
        plugins = [ "git" ];
      };
    };
  };
}
