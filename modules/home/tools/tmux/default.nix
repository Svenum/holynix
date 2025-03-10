{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.tools.tmux;
in
{
  options.holynix.tools.tmux = {
    enable = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      newSession = true;
      historyLimit = 5000;
      escapeTime = 100;
      clock24 = true;
      terminal = "screen-256color";
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
      ];
      extraConfig = ''
        # TMUX
        set -g repeat-time 700
        set -g mouse on

        set -g set-clipboard on

        bind-key c new-window -c "#{pane_current_path}"
        bind-key '"' split-window -c "#{pane_current_path}"
        bind-key % split-window -p 33 -h -c "#{pane_current_path}"

        bind-key ! break-pane -d -n _hidden_pane
        bind-key @ join-pane -s $.0 -h -l 33%
      '';
    };
  };
}
