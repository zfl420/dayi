#!/usr/bin/env python3
"""
Git Commit + Tag + Push - 轻量化自动提交与版本标记
"""

import subprocess
import sys
import re
from datetime import datetime


def run_command(command, description):
    """运行 shell 命令并返回结果"""
    try:
        result = subprocess.run(
            command,
            shell=True,
            check=True,
            capture_output=True,
            text=True
        )
        return True, result.stdout
    except subprocess.CalledProcessError as e:
        return False, e.stderr


def get_latest_version():
    """从远程仓库获取最新版本号"""
    # 获取远程所有版本 tag
    success, output = run_command(
        'git ls-remote --tags origin',
        "获取远程 tags"
    )

    if not success:
        print("获取远程 tags 失败，使用默认版本 v0.6.0")
        return "0.6.0"

    # 匹配版本号格式: v0.0.0-timestamp
    pattern = r'refs/tags/v(\d+)\.(\d+)\.(\d+)-'
    versions = []

    for line in output.strip().split('\n'):
        match = re.search(pattern, line)
        if match:
            major = int(match.group(1))
            minor = int(match.group(2))
            patch = int(match.group(3))
            versions.append((major, minor, patch))

    if not versions:
        # 没有找到版本 tag，使用默认版本
        return "0.6.0"

    # 找到最大版本号
    latest = max(versions)
    return f"{latest[0]}.{latest[1]}.{latest[2]}"


def increment_version(version_str):
    """递增版本号（十进制）"""
    parts = version_str.split('.')
    major = int(parts[0])
    minor = int(parts[1])
    patch = int(parts[2])

    # patch 递增
    patch += 1

    # 十进制进位：patch 满 10 进位到 minor
    if patch >= 10:
        patch = 0
        minor += 1

    # minor 满 10 进位到 major
    if minor >= 10:
        minor = 0
        major += 1

    return f"{major}.{minor}.{patch}"


def get_commit_message():
    """获取提交信息（默认值）"""
    if len(sys.argv) >= 2 and sys.argv[1].strip():
        return sys.argv[1].strip()
    return "chore: auto commit"


def has_changes():
    """检查是否有可提交的改动"""
    success, output = run_command(
        "git status --porcelain",
        "检查工作区状态"
    )
    if not success:
        print(f"❌ 获取工作区状态失败: {output}")
        sys.exit(1)
    return bool(output.strip())


def get_short_commit_hash():
    success, output = run_command(
        "git rev-parse --short HEAD",
        "获取提交哈希"
    )
    if not success:
        return ""
    return output.strip()


def show_status_summary():
    success, output = run_command(
        "git status -sb",
        "确认工作区状态"
    )
    if not success:
        print(f"❌ 获取工作区状态失败: {output}")
        return
    print(output.strip())


def push_commit():
    success, output = run_command(
        "git push",
        "推送 commit"
    )
    if success:
        return True, ""
    fallback_success, fallback_output = run_command(
        "git push origin HEAD",
        "推送 commit（origin HEAD）"
    )
    if fallback_success:
        return True, ""
    return False, fallback_output


def main():
    if not has_changes():
        print("没有可提交的改动，已退出。")
        return

    commit_message = get_commit_message()
    print(f"提交信息: {commit_message}")

    success, output = run_command(
        "git add -A",
        "添加改动"
    )
    if not success:
        print(f"❌ git add 失败: {output}")
        sys.exit(1)

    success, output = run_command(
        f'git commit -m "{commit_message}"',
        "提交改动"
    )
    if not success:
        print(f"❌ git commit 失败: {output}")
        sys.exit(1)

    commit_hash = get_short_commit_hash()
    if commit_hash:
        print(f"提交完成: {commit_hash}")

    # 获取最新版本并递增
    latest_version = get_latest_version()
    new_version = increment_version(latest_version)

    # 生成时间戳
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    tag_name = f"v{new_version}-{timestamp}"

    print(f"上一版本: v{latest_version}")
    print(f"正在创建 tag: {tag_name}")

    # 创建 tag
    success, output = run_command(
        f'git tag {tag_name}',
        "创建 tag"
    )
    if not success:
        print(f"❌ 创建 tag 失败: {output}")
        sys.exit(1)

    print("Tag 创建成功！")
    print("正在推送 commit...")

    success, output = push_commit()
    if not success:
        print(f"❌ 推送 commit 失败: {output}")
        print("提示: 请先设置上游分支或手动推送。")
        sys.exit(1)

    print("推送 commit 完成！")
    print("正在推送 tag...")

    # 推送 tag 到远程
    success, output = run_command(
        f'git push origin {tag_name}',
        "推送 tag"
    )
    if not success:
        print(f"❌ 推送 tag 失败: {output}")
        print(f"提示: 可以稍后手动推送: git push origin {tag_name}")
        sys.exit(1)

    print("推送 tag 完成！")
    print("")
    print("✓ 自动提交 + 版本备份完成")
    print("工作区状态:")
    show_status_summary()
    print(f"Tag: {tag_name}")


if __name__ == "__main__":
    main()
