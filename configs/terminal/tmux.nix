{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    clock24 = true;
    mouse = true;
    historyLimit = 100000;
    sensibleOnTop = true;
    plugins = with pkgs.tmuxPlugins; [ catppuccin sensible yank ];
    extraConfig = ''
      set -g status-position top
      set -g base-index 1
      setw -g pane-base-index 1
      bind -n C-Space last-window
      bind -n M-h select-pane -L
      bind -n M-l select-pane -R
      bind -n M-k select-pane -U
      bind -n M-j select-pane -D
      bind -n M-H resize-pane -L 5
      bind -n M-L resize-pane -R 5
      bind -n M-K resize-pane -U 3
      bind -n M-J resize-pane -D 3
    '';
  };
}


