---
title: 通过 GitHub Actions 自动部署 Hexo
date: 2019-08-23 20:14:27
tags:
  - Hexo
  - GitHub Pages
  - GitHub Actions
  - GitHub
categories: Notes
---

[GitHub Actions](https://help.github.com/en/articles/about-github-actions) 由 GitHub 官方推出的工作流工具。典型的应用场景应该是 CI/CD，类似 Travis 的用法。这里介绍响应 git push 事件触发 Hexo 编译静态页面并推送到 GitHub Pages 的用法。

### 准备工作

- 生成 ssh 部署私钥
    ```bash
    ssh-keygen -t ed25519 -f ~/.ssh/github-actions-deploy
    ```
- 在 GitHub repo 的 `Settings/Deploy keys` 中添加刚刚生成的公钥
- 在 GitHub repo 的 `Settings/Secrets` 中添加 `GH_ACTION_DEPLOY_KEY`，值为刚刚生成的私钥

### 编写 GitHub Actions

- 在项目的根目录添加 `deploy.yml`，目录结构如下
    ```
    .github
    └── workflows
    └── deploy.yml
    ```

- 步骤
    - 添加部署私钥到 GitHub Actions 执行的容器中
    - 在容器中安装 Hexo 以及相关的插件
    - 编译静态页面
    - 推送编译好的文件到 GitHub Pages

- 编写部署的 action

    ```yml
    name: compile and deploy to github page
    
    on:
      push:
        branches:
          - source
    
    jobs:
      build:
        #runs-on: macOS-latest
        runs-on: ubuntu-18.04
        steps:
        - uses: actions/checkout@v1
          with:
            submodules: true
            ref: refs/heads/source
    
        - uses: actions/setup-node@v1
          with:
            node_version: '12.x'
    
        - name: Compile and deploy blog
          run: |
              mkdir -p ~/.ssh/
              echo "$GH_ACTION_DEPLOY_KEY" > ~/.ssh/id_rsa
              chmod 600 ~/.ssh/id_rsa
              ssh-keyscan github.com >> ~/.ssh/known_hosts
              git config --global user.email "gong_chen@qq.com"
              git config --global user.name "gonchen"
              npm i -g hexo-cli
              npm i
              npm install hexo-renderer-jade hexo-renderer-stylus --save
              hexo g
              hexo d
          env:
            GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
            GH_ACTION_DEPLOY_KEY: ${{secrets.GH_ACTION_DEPLOY_KEY}}
    ```

### 小结

总的来说，就部署而言，速度比Travis部署速度更快一点。作为一站式的功能来说，还是不错的。

### 参考链接

- [Workflow syntax for GitHub Actions](https://help.github.com/en/articles/workflow-syntax-for-github-actions)

`---EOF---`