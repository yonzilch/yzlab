{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;

    # ── Core Behavior ──────────────────────────────────────────
    baseIndex = 1; # Window/pane numbering starts from 1, more intuitive
    escapeTime = 0; # Eliminate ESC delay, critical for Vim users
    historyLimit = 50000; # Keep more history scrollback lines
    newSession = true; # Auto-create session when none exists, avoid `attach` errors
    secureSocket = true; # Place socket in /run instead of /tmp, more secure

    # ── Keybindings and Interaction ────────────────────────────────────────
    keyMode = "vi"; # VI-style shortcuts (copy mode, etc.)
    customPaneNavigationAndResize = true; # Use hjkl / HJKL for pane navigation and resizing
    shortcut = "t"; # Prefix key Ctrl+t (more convenient than default Ctrl+b)
    resizeAmount = 5; # Move 5 rows/columns when resizing panes

    # ── Terminal Settings ──────────────────────────────────────────
    terminal = "tmux-256color"; # Ensure true color and 256-color support
    clock24 = true; # 24-hour format
    reverseSplit = true; # Reverse split (- horizontal, | vertical)

    # ── Plugins ──────────────────────────────────────────────
    # Note: NixOS plugins option only accepts package list, does not support HM attrset syntax
    plugins = with pkgs.tmuxPlugins; [
      catppuccin
      continuum
      sensible
      yank
      pain-control
      resurrect
    ];
    # ── Extra config before plugins ───────────────────────────────
    # tmux plugin @ variables must be declared before plugins are sourced to take effect
    extraConfigBeforePlugins = ''
      set -g @catppuccin_flavor "mocha"
      set -g @continuum-save-interval 15
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-processes ':all:'
    '';

    # ── Extra config after plugins ───────────────────────────────
    extraConfig = ''
      # ── True Color Support ──────────────────────────────────────
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides ",tmux-256color:Tc"

      # ── Mouse Support ────────────────────────────────────────
      set -g mouse on

      # ── Status Bar Refresh Interval ──────────────────────────────────
      set -g status-interval 5

      # ── Window Activity Alert ────────────────────────────────────
      set -g monitor-activity on
      set -g visual-activity off

      # ── Reload Config Shortcut ────────────────────────────
      bind r source-file /etc/tmux.conf \; display-message "Config reloaded!"

      # ── More Intuitive Pane Splitting ─────────────────────────────
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # ── Close Without Confirmation ────────────────────────────────────
      bind x kill-pane
      bind & kill-window

      # ── New Window Keeps Current Path ─────────────────────────────
      bind c new-window -c "#{pane_current_path}"

      # ── Quick Pane Switching (Vim style, no prefix)───────────────
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # ── Vi Copy Mode Enhancement ─────────────────────────────────
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # ── Automatic Window Renumbering ────────────────────────────────
      set -g renumber-windows on

      # ── Reduce Unnecessary Delay ────────────────────────────────
      set -s focus-events on

      # ── Mouse Selection Optimization ────────────────────────────────────
      # Auto-copy selected content and exit copy mode on mouse left button release
      bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-and-cancel
    '';
  };
}
