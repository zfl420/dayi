---
name: git-tag-push
description: "自动 commit、创建版本 tag 并推送（轻量化流程）"
---

# Git Commit + Tag + Push

自动提交当前改动，创建基于时间戳的版本 tag，并推送到远程仓库。

## 功能

- 自动 `git add -A`
- 自动 commit（支持自定义提交信息）
- 自动生成版本号 tag（格式：`v{major}.{minor}.{patch}-YYYYMMDD-HHMMSS`）
- 智能版本号递增（十进制，patch 满 10 进位到 minor）
- 从远程仓库自动获取最新版本并递增
- 起始版本：v0.6.0
- 自动推送 commit 与 tag

## 使用方法

### 方式 1：命令行调用

```bash
python3 .claude/skills/git-tag-push/scripts/commit_tag_push.py "chore: 自动提交"
```

### 方式 2：在 Claude Code 中使用

直接输入 `git-tag-push` 即可调用该 skill。

## 工作流程

1. 检查工作区是否有改动（无改动则直接退出，避免不必要的远程查询）
2. 从远程仓库获取最新版本号（格式：`v*.*.*-*`）
3. 智能递增版本号（patch + 1，满 10 进位）
4. 获取当前时间戳并生成 tag 名称
5. `git add -A`
6. `git commit -m <message>`（默认 `chore: auto commit`）
7. 创建 Git tag
8. 推送 commit（`git push`，若无上游则推送到 `origin`）
9. 推送 tag 到远程仓库

## 版本号递增规则

采用十进制递增规则：
- `v0.6.0` → `v0.6.1` → `v0.6.2` → ... → `v0.6.9` → `v0.7.0`
- `v0.9.9` → `v1.0.0`
- patch 满 10 进位到 minor
- minor 满 10 进位到 major

## 示例输出

```
提交信息: chore: auto commit
提交完成: 1a2b3c4
上一版本: v0.6.1
正在创建 tag: v0.6.2-20260105-191153
Tag 创建成功！
正在推送 commit...
推送 commit 完成！
正在推送 tag...
推送 tag 完成！

✓ 自动提交 + 版本备份完成
Tag: v0.6.2-20260105-191153
```

## 注意事项

- 确保当前目录是一个 Git 仓库
- 确保有远程仓库配置（origin）
- 确保有推送权限
