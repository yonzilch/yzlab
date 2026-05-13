{pkgs, ...}: {
  programs.tmux = {
    enable = true;

    # ── 核心行为 ──────────────────────────────────────────
    baseIndex = 1; # 窗口/面板编号从 1 开始，更直观
    escapeTime = 0; # 消除 ESC 延迟，对 Vim 用户至关重要
    historyLimit = 50000; # 保留更多历史回滚行数
    newSession = true; # 无 session 时自动创建，避免 `attach` 报错
    secureSocket = true; # 将 socket 放在 /run 而非 /tmp，更安全

    # ── 键位与交互 ────────────────────────────────────────
    keyMode = "vi"; # VI 风格快捷键（复制模式等）
    customPaneNavigationAndResize = true; # 用 hjkl / HJKL 导航和调整面板
    shortcut = "t"; # 前缀键 Ctrl+a（比默认 Ctrl+b 更顺手）
    resizeAmount = 5; # 每次调整面板大小移动 5 行/列

    # ── 终端设置 ──────────────────────────────────────────
    terminal = "tmux-256color"; # 确保真彩色与 256 色支持
    clock24 = true; # 24 小时制
    reverseSplit = true; # 反向分割（- 水平，| 垂直）

    # ── 插件 ──────────────────────────────────────────────
    # 注意：NixOS 的 plugins 选项只接受 package 列表，不支持 HM 的 attrset 语法
    plugins = with pkgs.tmuxPlugins; [
      catppuccin
      continuum
      sensible
      yank
      pain-control
      resurrect
    ];
    # ── 插件加载前的额外配置 ───────────────────────────────
    # tmux 插件的 @ 变量需要在插件被 source 之前声明才能生效
    extraConfigBeforePlugins = ''
      set -g @catppuccin_flavor "mocha"
      set -g @continuum-save-interval 15
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-processes ':all:'
    '';

    # ── 插件加载后的额外配置 ───────────────────────────────
    extraConfig = ''
      # ── 真彩色支持 ──────────────────────────────────────
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides ",tmux-256color:Tc"

      # ── 鼠标支持 ────────────────────────────────────────
      set -g mouse on

      # ── 状态栏刷新间隔 ──────────────────────────────────
      set -g status-interval 5

      # ── 窗口活动提示 ────────────────────────────────────
      set -g monitor-activity on
      set -g visual-activity off

      # ── 重新加载配置的快捷键 ────────────────────────────
      bind r source-file /etc/tmux.conf \; display-message "Config reloaded!"

      # ── 更直觉的分屏快捷键 ─────────────────────────────
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # ── 关闭无需确认 ────────────────────────────────────
      bind x kill-pane
      bind & kill-window

      # ── 新窗口保持当前路径 ─────────────────────────────
      bind c new-window -c "#{pane_current_path}"

      # ── 快速切换面板（Vim 风格，无需前缀）───────────────
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # ── Vi 复制模式增强 ─────────────────────────────────
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # ── 窗口编号自动重排 ────────────────────────────────
      set -g renumber-windows on

      # ── 减少不必要的延迟 ────────────────────────────────
      set -s focus-events on

      # ── 鼠标选取优化 ────────────────────────────────────
      # 松开鼠标左键时，自动复制选中内容并退出复制模式
      bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-and-cancel
    '';
  };
}
