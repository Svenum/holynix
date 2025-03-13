{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.tools.tmux;
  themeCfg = config.holynix.theme;
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
        catppuccin
        vim-tmux-navigator
      ];
      extraConfigBeforePlugins = ''
        # Catppuccin
        set -g @catppuccin_flavor '${themeCfg.flavor}'
        set -g @catppuccin_status_modules_right "application session user host date_time"
        set -g @catppuccin_date_time_text "%d.%m.%Y %H:%M"
        
        set -g @catppuccin_window_right_separator " "
        set -g @catppuccin_window_left_separator "█"
        set -g @catppuccin_window_middle_separator " "
        
        set -g @catppuccin_status_left_separator " "
        set -g @catppuccin_status_right_separator "█"

        set -g @catppuccin_status_fill "all"
        set -g @catppuccin_status_connect_separator "no"

        set -g @catppuccin_window_current_text "#{pane_current_path}"
        set -g @catppuccin_window_number_position "right"
        set -g @catppuccin_window_default_fill "number"
        set -g @catppuccin_window_current_fill "all"
      '';
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
