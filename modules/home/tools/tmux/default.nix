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
    catppuccin.tmux.extraConfig = ''
      # Pane
      set -g @catppuccin_pane_default_text ""

      # Window
      set -g @catppuccin_window_status_style "custom"
      set -q @catppuccin_window_flag "text"
      set -g window-status-separator ""

      ## Window global/default configuration
      set -g @catppuccin_window_text_color "#{@thm_teal}"
      set -g @catppuccin_window_text "#[reverse]#{window_name}#[none]"
      set -g @catppuccin_window_status "icon"
      set -g @catppuccin_window_number "#[reverse] #I#[none]"
      set -g @catppuccin_window_number_position "left"

      set -g @catppuccin_window_left_separator "#[fg=#{@catppuccin_window_current_number_color},bg=#{@thm_bg}]█#[none]"
      set -g @catppuccin_window_middle_separator "#[fg=#{@catppuccin_window_current_number_color},bg=#{@thm_surface_0}]█ #[none]"
      set -g @catppuccin_window_right_separator "#[fg=#{@thm_surface_0},bg=#{@thm_bg}]█#[none]"
      set -g @catppuccin_window_text "#[fg=#{@thm_surface_0},reverse]#{window_name}#[none]"

      ## Window current configuration
      set -g @catppuccin_window_current_text_color "#{@thm_teal}"
      set -g @catppuccin_window_current_number_color "#{@thm_teal}"
      set -g @catppuccin_window_current_text "#[fg=#{@thm_surface_0}]#W#[none]"
      set -g @catppuccin_window_current_number "#[reverse] #I#[none]"
      set -g @catppuccin_window_current_middle_separator "#[fg=#{@catppuccin_window_current_number_color},bg=#{@thm_bg},reverse] 󰿟 #[none]"
      set -g @catppuccin_window_current_right_separator "#[fg=#{@catppuccin_window_current_number_color},bg=#{@thm_bg}]█#[none]"

      # Status
      set -g status-right-length 100
      set -g status-left ""
      set -g status-right ""

      ## Status global/default configuration
      set -g @catppuccin_status_left_separator "█"
      set -g @catppuccin_status_middle_separator "#[fg=#{@thm_surface_0},reverse]█#[none]"
      set -g @catppuccin_status_right_separator "█"
      set -g @catppuccin_status_connect_separator "no"

      # Status modules
      set -g status-right-length 0
      set -ag status-right "#{E:@catppuccin_status_user}"
      set -ag status-right "#{E:@catppuccin_status_host}"
      set -ag status-right "#{E:@catppuccin_status_date_time}"

      # Moduels
      set -g @catppuccin_date_time_text " %d.%m.%Y %H:%M"
    '';
  };
}
