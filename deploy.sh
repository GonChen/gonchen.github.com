#!/bin/bash
# Deploy VitePress site to GitHub Pages
set -e

cd "$(dirname "$0")"

echo "🔨 Building VitePress..."
npm run docs:build

DEPLOY_DIR="/tmp/vitepress-deploy-$$"
cp -r docs/.vitepress/dist "$DEPLOY_DIR"
echo "blog.coolgpu.cn" > "$DEPLOY_DIR/CNAME"
cd "$DEPLOY_DIR"

echo "🚀 Deploying to gh-pages branch..."
touch .nojekyll
git init
git config user.name "chen"
git config user.email "chen@qq.com"
git remote add origin git@github.com:GonChen/gonchen.github.com.git
git add -A
git commit -m "deploy: $(date '+%Y-%m-%d %H:%M')"
git branch -M master
git push --force origin master

echo "✅ Deployed! https://gonchen.github.io/"