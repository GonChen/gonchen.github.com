# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Personal static site for sharing Agent-generated HTML articles. No build step — pure HTML deployed to GitHub Pages at `blog.coolgpu.cn`.

## Structure

```
/
├── index.html              # Home page (hand-maintained)
├── pages/                  # Pages: YYYY-MM-DD-slug.html
├── assets/                 # Page assets: assets/YYYY-MM-DD-slug/
├── templates/              # Reference templates for Agent
├── public/                 # Site-wide static assets (favicon)
├── PUBLISH.md              # Agent publishing guide
├── CONTEXT.md              # Domain glossary
└── deploy.sh               # Deploy to GitHub Pages
```

## Commands

- `bash deploy.sh` — Deploy static files to GitHub Pages (master branch)
- `python3 scripts/migrate-md-to-html.py` — One-time MD→HTML migration (legacy)

## Workflow

1. Read `templates/tech-article.html` as starting point
2. Create `pages/YYYY-MM-DD-slug.html` with Page Meta in `<head>`
3. Put images in `assets/YYYY-MM-DD-slug/`
4. Manually add entry to `index.html` (see `PUBLISH.md`)
5. Run `bash deploy.sh` to deploy

## Key conventions

- **Page**: Self-contained HTML file in `pages/`
- **Page Meta**: `<title>`, `<meta name="date">`, `<meta name="summary">` in `<head>`
- **Site Nav**: Fixed top bar `← CoolGPU` linking to `/`
- **Paths**: Always absolute (`/pages/...`, `/assets/...`)
- **WeChat-friendly**: 16px base font, no external fonts, responsive images/tables

See `PUBLISH.md` for full publishing guide and `CONTEXT.md` for terminology.
