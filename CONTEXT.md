# CoolGPU 个人站点

Agent 生成 HTML 文章的极简静态站点。只有主页（Index）和子页面（Page），无 Markdown 转换管线。

## Language

**Index**:
站点唯一入口页，列出所有已发布的 Page，提供导航。手写维护，不由脚本生成。
_Avoid_: 首页, home, landing

**Page**:
一篇可独立发布的自包含 HTML 文件，拥有自己的编排与风格，不依赖站点构建工具渲染。存放在 `pages/` 下，命名为 `YYYY-MM-DD-slug.html`。
_Avoid_: 文章, post, article（作为文件类型时）

**Page Meta**:
写在 Page 的 `<head>` 内的标准 `<meta>` 标签。必填：`title`、`date`、`summary`；可选：`tags`。Index 手写时不强制扫描，但建议保留以便日后自动化。
_Avoid_: frontmatter, sidecar, meta.json

**Site Nav**:
每个 Page 顶部的固定返回栏，链接回 Index（`href="/"`）。模板默认包含，特殊 Page 可删除。
_Avoid_: 导航栏, navbar, breadcrumb

**Template**:
放在 `templates/` 下的完整 HTML 参考范例，供 Agent 复制改写后输出 Page。不是构建输入，部署时一并发布供在线参考。
_Avoid_: 布局引擎, layout, theme

**Asset**:
Page 的图片等资源，存放在 `assets/YYYY-MM-DD-slug/` 下，Page 内用绝对路径 `/assets/...` 引用。
_Avoid_: 附件, media, static
