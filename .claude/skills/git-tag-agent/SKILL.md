---
name: git-tag-agent
description: "快速创建版本备份点，自动打 tag 并推送"
---

# Git Tag Agent - 版本备份工具

自动创建基于时间戳的 Git tag，快速为项目创建版本备份点。

## 功能

- 自动生成版本号 tag（格式：`v{major}.{minor}.{patch}-YYYYMMDD-HHMMSS`）
- 智能版本号递增（十进制，patch 满 10 进位到 minor）
- 从远程仓库自动获取最新版本并递增
- 起始版本：v0.6.0
- 自动推送 tag 到远程仓库
- 一键完成版本备份

## 使用方法

### 方式 1：命令行调用

```bash
python3 .claude/skills/git-tag-agent/scripts/tag.py
```

### 方式 2：在 Claude Code 中使用

直接输入 `git-tag-agent` 即可调用该 skill。

## 工作流程

1. 从远程仓库获取最新版本号（格式：`v*.*.*-*`）
2. 智能递增版本号（patch + 1，满 10 进位）
3. 获取当前时间戳
4. 生成 tag 名称（格式：`v{版本号}-YYYYMMDD-HHMMSS`）
5. 创建 Git tag
6. 推送 tag 到远程仓库
7. 显示成功消息

## 版本号递增规则

采用十进制递增规则：
- `v0.6.0` → `v0.6.1` → `v0.6.2` → ... → `v0.6.9` → `v0.7.0`
- `v0.9.9` → `v1.0.0`
- patch 满 10 进位到 minor
- minor 满 10 进位到 major

## 示例输出

```
上一版本: v0.6.1
正在创建 tag: v0.6.2-20260105-191153
Tag 创建成功！
正在推送到远程仓库...
推送完成！

✓ 版本备份完成
Tag: v0.6.2-20260105-191153
```

## 注意事项

- 确保当前目录是一个 Git 仓库
- 确保有远程仓库配置（origin）
- 确保有推送权限
