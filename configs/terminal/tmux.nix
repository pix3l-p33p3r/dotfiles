{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    clock24 = true;
    mouse = true;
    historyLimit = 100000;
    sensibleOnTop = true;
    plugins = with pkgs.tmuxPlugins; [ catppuccin sensible yank ];
    extraConfig = ''
      # True color passthrough — Kitty sets TERM=xterm-kitty outside tmux;
      # these overrides tell tmux to forward 24-bit RGB sequences inward.
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -ag terminal-overrides ",xterm-kitty:RGB"

      set -g status-position top

      # 1-based window/pane numbering so numbers match keyboard layout
      set -g base-index 1
      setw -g pane-base-index 1

      # Keep window numbers contiguous after closing one
      set -g renumber-windows on

      # ── Navigation (no prefix) ──────────────────────────────────────────
      bind -n M-h select-pane -L
      bind -n M-l select-pane -R
      bind -n M-k select-pane -U
      bind -n M-j select-pane -D

      # ── Resize (no prefix) ─────────────────────────────────────────────
      bind -n M-H resize-pane -L 5
      bind -n M-L resize-pane -R 5
      bind -n M-K resize-pane -U 3
      bind -n M-J resize-pane -D 3

      # ── Quick last-window toggle ────────────────────────────────────────
      bind -n C-Space last-window
    '';
  };
}
