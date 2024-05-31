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
      ];
      extraConfigBeforePlugins = ''
        set -g repeat-time 700
        set -g mouse on
        set -g @catppuccin_flavour '${themeCfg.flavour}'
        set -g @catppuccin_status_modules_right "application session user host date_time"
        set -g @catppuccin_date_time_text "%d.%m.%Y %H:%M"
        
        set -g @catppuccin_window_right_separator " "
        set -g @catppuccin_window_left_separator "█"
        set -g @catppuccin_window_middle_separator " █"
        set -g @catppuccin_window_left_separator_inverse "yes"
        
        set -g @catppuccin_status_left_separator " "
        set -g @catppuccin_status_right_separator "█"

        set -g @catppuccin_status_fill "all"
        set -g @catppuccin_status_connect_separator "yes"

        set -g @catppuccin_window_current_text "#{pane_current_path}"
        set -g @catppuccin_window_number_position "right"
        set -g @catppuccin_window_default_fill "number"
      '';
    };
  };
}
