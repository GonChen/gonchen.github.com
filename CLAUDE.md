# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Personal blog built with [VitePress](https://vitepress.dev/), deployed to GitHub Pages. Posts are markdown files under `docs/YYYY/MM/DD/` with YAML frontmatter (title, date, tags, categories).

## Commands

- `npm run docs:dev` — Start local dev server with hot-reload
- `npm run docs:build` — Build static site to `docs/.vitepress/dist`
- `npm run docs:preview` — Preview built site locally
- `bash deploy.sh` — Build + force-push to `gh-pages` branch (master)
- `bash scripts/sync-index.sh` — Scan all posts and auto-update home page features, sidebar, and archives page

## Workflow

1. Create a new `.md` file under `docs/YYYY/MM/DD/` with proper frontmatter (title, date, tags, categories)
2. Insert `<!-- more -->` after the intro paragraph to control excerpt shown on home page
3. Run `bash scripts/sync-index.sh` to update index/sidebar/archives
4. Run `npm run docs:build` to verify build passes
5. Run `bash deploy.sh` to deploy

## Architecture

- `docs/` — All site content (markdown files + VitePress config)
  - `docs/.vitepress/config.mjs` — Site config (nav, sidebar, social links, footer)
  - `docs/index.md` — Home page with hero + features (auto-updated by sync-index.sh)
  - `docs/archives.md` — Archive listing (auto-updated by sync-index.sh)
  - `docs/tags.md` — Tags page
  - `docs/about.md` — About page
- `scripts/sync-index.sh` — Automation: parses frontmatter from all posts and regenerates index.md features, config.mjs sidebar, and archives.md
- `deploy.sh` — Builds then force-pushes to `git@github.com:GonChen/gonchen.github.com.git` master branch