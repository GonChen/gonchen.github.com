import { defineConfig } from 'vitepress'

export default defineConfig({
  title: "辰的博客",
  description: "寻找乐趣,寻找生活",
  lang: 'zh-CN',
  base: '/',
  head: [
    ['link', { rel: 'icon', href: '/favicon.ico' }]
  ],
  themeConfig: {
    nav: [
      { text: '首页', link: '/' },
      { text: '归档', link: '/archives' },
      { text: '标签', link: '/tags' },
      { text: '关于', link: '/about' },
    ],
    sidebar: [
      {
        text: '文章',
        items: [
          { text: 'Index', link: '/' },
          { text: 'Windows + tmux + Claude Code：持久化 SSH 会话工作流', link: '/2026/06/02/windows-tmux-claude-code-ssh' },
          { text: 'X 社区热议：Attention Kernel 优化趋势 (2026-05)', link: '/2026/05/31/attention-kernel-x-search-2026-05' },
          { text: 'Attention Kernel Optimization 研究报告', link: '/2026/05/31/attention-kernel-optimization-report-2026-05' },
        ]
      }
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/GonChen' }
    ],
    footer: {
      message: 'Built with VitePress',
      copyright: '© 2026 Gong Chen'
    }
  }
})
