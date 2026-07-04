#!/bin/bash
# Deploy static site to GitHub Pages
set -e

cd "$(dirname "$0")"

echo "📦 Preparing static site..."
DEPLOY_DIR="/tmp/static-deploy-$$"
mkdir -p "$DEPLOY_DIR"

cp index.html "$DEPLOY_DIR/"
cp -r pages assets public templates "$DEPLOY_DIR/"
echo "blog.coolgpu.cn" > "$DEPLOY_DIR/CNAME"

cd "$DEPLOY_DIR"
touch .nojekyll

echo "🚀 Deploying to GitHub Pages..."
git init
git config user.name "chen"
git config user.email "chen@qq.com"
git remote add origin git@github.com:GonChen/gonchen.github.com.git
git add -A
git commit -m "deploy: $(date '+%Y-%m-%d %H:%M')"
git branch -M master
git push --force origin master

echo "✅ Deployed! https://blog.coolgpu.cn/"
