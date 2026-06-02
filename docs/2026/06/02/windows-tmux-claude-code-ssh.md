---
title: Windows + tmux + Claude Code：持久化 SSH 会话工作流
date: 2026-06-02
tags: ['tmux', 'Claude Code', 'SSH', 'Windows', 'WSL', 'terminal']
categories: [工具链]
---

> 参考：[Using tmux with Claude Code for Persistent SSH Sessions](https://brendanjameslynskey.github.io/TMUX_with_Claude_Code/) · [Tmux + Claude Code + SSH Persistent Session](https://treeru.com/en/blog/tmux-claude-code-ssh-persistent-session) ·

在本地 PC（Windows）上用 Claude Code 通过 SSH 连接远程 Linux 开发机时，网络抖动、VPN 断开、Windows 更新重启等任何中断都会导致 Claude Code 进程被 kill，宝贵的对话上下文丢失，不得不从头开始。**tmux** 完美解决了这个问题——它在远程机器上保持会话，本地客户端可以随时重连，断开也不会影响远程任务的继续执行。

<!-- more -->

## 为什么需要 tmux + Claude Code

Claude Code 是一个终端内的 AI 编程助手，它的核心优势是上下文管理能力——在一次会话中可以持续积累对项目结构、代码逻辑和任务目标的理解。但这也意味着，**一旦会话中断，上下文就会丢失**。

典型场景：

- 你在 Windows 上用 WSL 或 PowerShell，`ssh` 到 Linux 开发机跑 Claude Code
- 网络不稳定、VPN 超时、合上笔记本盖子
- SSH 连接断开 → Claude Code 进程收到 SIGHUP → 进程终止 → 下次重连只能从头开始

**tmux 作为终端复用器**，在远程机器上独立运行你的会话，不受本地连接状态影响：

```
┌──────────────┐     SSH      ┌──────────────────┐
│  Windows PC  │ ──────────→  │  Linux Dev Host  │
│  (terminal)  │              │  ├─ tmux session │
└──────────────┘              │  │  └─ claude    │
    断开不影响 ────────→      │  └───────────────┘
```

## 基本工作流

### 1. SSH 连接到远程机器

```bash
ssh user@dev-server
```

### 2. 创建或恢复 tmux 会话

```bash
# 创建新会话
tmux new -s claude

# 或者下次重连时恢复已有会话
tmux attach -t claude

# 查看所有会话
tmux ls
```

### 3. 在 tmux 中启动 Claude Code

```bash
cd /path/to/your/project
claude
```

现在你可以正常使用 Claude Code。即使本地 SSH 断开：

- `tmux attach -t claude` 回到刚才的会话
- Claude Code 状态完好无损

### 4. 断开与重连

本地断开 SSH（主动关闭或网络中断）后，在 tmux 中运行的所有进程继续执行。重新 SSH 连上后：

```bash
ssh user@dev-server
tmux attach -t claude
```

## 进阶技巧

### 与 VS Code 集成

VS Code 的 Remote-SSH 插件同样可以使用 tmux：

1. `Ctrl+`` 打开 VS Code 终端（已自动 SSH 到远程）
2. `tmux new -t claude -s claude` 创建会话
3. `claude` 启动 Claude Code

VS Code 断开重连后，终端内 tmux 会话依然存活，`tmux attach` 即可恢复。

### 窗口分割 — Claude Code + 编辑器 + 终端

tmux 真正的威力在于**多面板工作流**：

```
┌──────────────────────────────────────┐
│          Claude Code 主面板           │
│                                      │
│                                      │
├───────────────────┬──────────────────┤
│  代码阅读 / 编辑  │  编译 / 测试     │
│  (less/vim/nvim)  │  (make/npm/go)  │
└───────────────────┴──────────────────┘
```

```bash
# 水平分割（上下）
tmux split-window -v

# 垂直分割（左右）
tmux split-window -h

# 在面板间切换
Ctrl-b + 方向键
```

经典工作流：左侧 Claude Code 面板，右侧上方用 `less` 或 `nvim` 阅读代码，右侧下方跑构建命令。

### 滚动与搜索

Claude Code 的输出很长时：

- `Ctrl-b [` 进入滚动模式（Vi 方向键翻页）
- `/keyword` 搜索关键词
- `q` 退出滚动模式

配合 `set -g history-limit 200000` 可保留大量历史输出（见下方配置）。

## 我的 tmux 配置

以下是 `~/.tmux.conf` 实际配置，适配 Claude Code 使用场景：

```tmux
# --- Agent / SSH / TUI (16spc) ---
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g focus-events on
set -g set-clipboard on
set -g status-position top

set -g history-limit 200000
set -g allow-passthrough off
set -g mouse on

set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"
set -ag terminal-overrides ",tmux-256color:RGB"
set -g escape-time 50

setw -g mode-keys vi

# prefix + Alt-r: clear stuck mouse reporting
bind-key -n M-r run-shell 'printf "\033[?1000l\033[?1002l\033[?1003l\033[?1006l"' \; display-message "mouse escape reset"

# prefix + M: toggle mouse
bind-key M set -g mouse \; display-message "mouse #{?mouse,on,off}"

# --- TPM (prefix + I install, prefix + U update) ---
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-restore 'on'
run '~/.tmux/plugins/tpm/tpm'
```

### 关键配置说明

| 配置项 | 作用 |
|--------|------|
| `focus-events on` | 允许 tmux 面板获得/失去焦点时通知应用，Claude Code 能正确响应焦点事件 |
| `history-limit 200000` | 保留 20 万行回滚历史 |
| `mouse on` | 鼠标点击切换面板、滚动 |
| `mode-keys vi` | 滚动模式下 Vi 键位（`j`/`k` 翻行, `Ctrl-u`/`Ctrl-d` 翻页） |
| `default-terminal tmux-256color` | 256 色 + 真彩色支持，Claude Code 代码高亮正确渲染 |
| `escape-time 50` | 减少 Esc 键延迟，避免在 Vim/Neovim ESC 时产生误判 |

### 插件系统

通过 TPM（Tmux Plugin Manager）管理两个核心插件：

- **tmux-resurrect** — 保存/恢复 tmux 会话状态（面板布局、工作目录、甚至进程）
- **tmux-continuum** — 每 15 分钟自动保存，tmux 启动时自动恢复最新状态

安装插件：在 tmux 内按 `Ctrl-b + I`（大写 I）。

### 鼠标模式异常恢复

偶尔 SSH 断开重连后鼠标状态会"卡住"（终端仍然认为鼠标处于跟踪模式），此时按 **`Alt-r`** 即可重置鼠标控制序列，无需关闭 tmux 或重连。

## Windows 端的准备

在 Windows 上连接到远程 Linux 开发机，推荐两种方式：

### 方式一：Windows Terminal + OpenSSH（推荐）

Windows 10/11 自带 OpenSSH 客户端：

```powershell
# 如果未安装，管理员 PowerShell：
Add-WindowsCapability -Online -Name OpenSSH.Client*

# 连接
ssh user@dev-server
```

配合 [Windows Terminal](https://github.com/microsoft/terminal) 获得最佳终端体验。

### 方式二：WSL

如果已在 WSL 中工作（且 SSH key 配置在 WSL 内）：

```bash
# WSL 终端中
ssh user@dev-server
tmux new -s claude
claude
```

我个人的做法是在 **Windows Terminal** 中配置多个 Tab/Profile，WSL 和远程 SSH 各占一个 Tab，本地的 WSL 终端用于文件操作和 Git，远程 tmux 会话用于 Claude Code。

## 完整工作流总结

```
首次建立 / 日常使用:

  Windows Terminal → ssh user@dev → tmux new -s claude  →  cd project  →  claude
                                    ↑
                                  已有会话: tmux attach -t claude

断开后重连:

  Windows Terminal → ssh user@dev → tmux attach -t claude
                                   ↑
                             一切照旧，上下文还在
```

这套工作流稳定运行数月，再未因 SSH 断开丢失过任何 Claude Code 上下文。