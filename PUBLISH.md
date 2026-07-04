# 发布指南

Agent 向 CoolGPU 个人站点发布新 Page 时，按以下步骤操作。

## 目录结构

```
/
├── index.html                          # 主页（手写维护）
├── pages/YYYY-MM-DD-slug.html          # Page 文件
├── assets/YYYY-MM-DD-slug/             # Page 图片资源
├── templates/tech-article.html         # 技术文章参考范例
└── public/favicon.svg                  # 站点图标
```

## 发布流程

### 1. 读模板

阅读 `templates/tech-article.html`，复制其结构作为起点。

### 2. 创建 Page

输出到 `pages/YYYY-MM-DD-slug.html`。命名规则：

- 日期：`YYYY-MM-DD`（文章日期）
- slug：英文小写 + 连字符，简短描述主题
- 示例：`pages/2026-07-04-ai-agent-conference.html`

### 3. 填写 Page Meta

`<head>` 中必填：

```html
<title>文章标题</title>
<meta name="date" content="2026-07-04">
<meta name="summary" content="一句话摘要">
```

可选：

```html
<meta name="tags" content="标签1, 标签2">
```

### 4. 放置图片

图片放 `assets/YYYY-MM-DD-slug/`，Page 内用绝对路径引用：

```html
<img src="/assets/2026-07-04-ai-agent-conference/cover.png" alt="描述">
```

### 5. 更新 Index

在 `index.html` 的 `<div class="page-list">` **最上方**插入：

```html
<article class="page-entry">
  <time datetime="2026-07-04">2026-07-04</time>
  <h2><a href="/pages/2026-07-04-slug.html">文章标题</a></h2>
  <p class="summary">一句话摘要</p>
</article>
```

### 6. 部署

```bash
bash deploy.sh
```

## 约定

| 项目 | 规则 |
|------|------|
| Site Nav | 每页顶部 `<nav class="site-nav"><a href="/">← CoolGPU</a></nav>`，特殊 Page 可删除 |
| 路径 | 一律用绝对路径（`/pages/...`、`/assets/...`） |
| 字体 | 不依赖 Google Fonts 等外链字体（微信友好） |
| 字号 | `body { font-size: 16px; }` 防止 iOS 自动放大 |
| 图片 | `max-width: 100%; height: auto;` |
| 表格 | 包在 `<div class="table-wrap">` 内，支持手机横滑 |
| 代码块 | `overflow-x: auto; -webkit-overflow-scrolling: touch` |

## 特殊 Page

需要完全自定义编排时，不必套用模板样式，但建议保留：

- `<meta charset>` 和 viewport
- Page Meta 标签
- Site Nav（可删除）

术语定义见根目录 `CONTEXT.md`。
