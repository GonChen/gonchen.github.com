# 0001 Static HTML over VitePress

站点从 VitePress（Markdown → 静态站）迁移为纯静态 HTML。每篇 Page 是自包含的 `.html` 文件，Agent 可直接生成并发布，无需构建步骤。

**为何放弃 VitePress：** Markdown 转换会损失编排信息（自定义布局、内联样式、复杂表格/图片排列），而 Agent 生成的 HTML 文章需要完整保留视觉效果。

**为何选手写 Index：** 站点极简（Index + Pages），列表条目少，手写比脚本生成更可控；Page 的 `<meta>` 标签保留以备日后自动化。

**为何零构建：** 去掉 npm/VitePress 依赖，部署时直接推送静态文件到 GitHub Pages，降低 Agent 发布链路复杂度。
