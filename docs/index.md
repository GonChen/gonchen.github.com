---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "CoolGPU"
  text: "寻找乐趣,寻找生活"
  tagline: ML / GPU Kernel / 技术笔记
  actions:
    - theme: brand
      text: 📖 全部文章
      link: /archives

features:
  - title: "Windows + tmux + Claude Code：持久化 SSH 会话工作流"
    details: "在本地 PC（Windows）上用 Claude Code 通过 SSH 连接远程 Linux 开发机时，网络抖动、VPN 断开、Windows 更新重启等任何中断都会导致 Claude Code 进程被 kill，宝贵的对话上下文丢失，不得不从头开始。**tmux** 完美解决了这个问题——它在远程机器上保持会话，本地客户端可以随时重连，断开也不会影响远程任务的继续执行。"
    link: /2026/06/02/windows-tmux-claude-code-ssh
  - title: "X 社区热议：Attention Kernel 优化趋势 (2026-05)"
    details: "Great technical talk by @tedzadouri on FlashAttention-4: a deep look at how attention kernels are being redesigned for NVIDIA Blackwell, where the bottleneck shifts from tensor cores to softmax + memory movement."
    link: /2026/05/31/attention-kernel-x-search-2026-05
  - title: "Attention Kernel Optimization 研究报告"
    details: "封面速览：FlashAttention-4 登顶 Blackwell（1,613 TFLOPs/s），FlashQLA 和 cuLA 代表线性 attention 两条路径，社区掀起手写 attention kernel 热潮。"
    link: /2026/05/31/attention-kernel-optimization-report-2026-05

