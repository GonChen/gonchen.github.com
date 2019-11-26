#!/bin/sh
rm -rf public
git clone -b master "https://gonchen:${GITHUB_TOKEN}@github.com/GonChen/gonchen.github.com.git" public
cd public
git rm -rf *
echo "NO JEKYLL! I LOVE HEXO" > .nojekyll
cd ..
# hexo generate
npm run hexo r
cd public
git add .

git commit -m "Update site on $(date -u)"
git push origin master
