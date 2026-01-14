#!/usr/bin/env python3
"""
Git Commit + Tag + Push - 轻量化自动提交与版本标记
"""

import subprocess
import sys
import re
from datetime import datetime
from subprocess import TimeoutExpired


def run_command(command, description, timeout=30):
    """运行 shell 命令并返回结果"""
    try:
        result = subprocess.run(
            command,
            shell=True,
            check=True,
            capture_output=True,
            text=True,
            timeout=timeout
        )
        return True, result.stdout
    except subprocess.TimeoutExpired:
        return False, f"命令执行超时（{timeout}秒）"
    except subprocess.CalledProcessError as e:
        return False, e.stderr


def get_latest_version_from_remote():
    """从远程仓库获取最新版本号（必须从远程获取以确保一致性）"""
    print("正在从远程获取最新版本号...")

    # 匹配版本号格式: v0.0.0-timestamp
    pattern = r'v(\d+)\.(\d+)\.(\d+)-'

    # 从远程获取所有 tags
    success, output = run_command(
        'git ls-remote --tags origin',
        "获取远程 tags",
        timeout=120
    )

    if not success:
        print("❌ 获取远程 tags 失败")
        print(f"错误信息: {output}")
        sys.exit(1)

    versions = []
    for line in output.strip().split('\n'):
        if not line:
            continue
        # 远程格式: refs/tags/v0.0.0-timestamp
        match = re.search(r'refs/tags/' + pattern, line)
        if match:
            major = int(match.group(1))
            minor = int(match.group(2))
            patch = int(match.group(3))
            versions.append((major, minor, patch))

    if not versions:
        print("远程未找到任何版本 tag，将从 v0.0.0 开始")
        return "0.0.0"

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


def push_commit():
    print("正在推送 commit...")
    success, output = run_command(
        "git push",
        "推送 commit",
        timeout=120
    )
    if success:
        return True, ""
    print("尝试备用推送方式...")
    fallback_success, fallback_output = run_command(
        "git push origin HEAD",
        "推送 commit（origin HEAD）",
        timeout=120
    )
    if fallback_success:
        return True, ""
    return False, fallback_output


def main():
    # 第1步：首先从远程获取最新版本号（必须先执行）
    latest_version = get_latest_version_from_remote()
    new_version = increment_version(latest_version)

    # 生成时间戳和新 tag 名称
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    tag_name = f"v{new_version}-{timestamp}"

    print(f"远程最新版本: v{latest_version}")
    print(f"即将创建版本: {tag_name}")
    print("")

    # 第2步：检查是否有改动
    if not has_changes():
        print("没有可提交的改动，已退出。")
        return

    # 第3步：获取提交信息
    commit_message = get_commit_message()
    print(f"提交信息: {commit_message}")

    # 第4步：添加改动
    success, output = run_command(
        "git add -A",
        "添加改动"
    )
    if not success:
        print(f"❌ git add 失败: {output}")
        sys.exit(1)

    # 第5步：提交改动
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

    # 第6步：创建 tag
    print(f"正在创建 tag: {tag_name}")
    success, output = run_command(
        f'git tag {tag_name}',
        "创建 tag"
    )
    if not success:
        print(f"❌ 创建 tag 失败: {output}")
        sys.exit(1)

    print("Tag 创建成功！")

    # 第7步：推送 commit
    success, output = push_commit()
    if not success:
        print(f"❌ 推送 commit 失败: {output}")
        print("提示: 请先设置上游分支或手动推送。")
        sys.exit(1)

    print("✓ 推送 commit 完成！")

    # 第8步：推送 tag
    print("正在推送 tag...")
    success, output = run_command(
        f'git push origin {tag_name}',
        "推送 tag",
        timeout=120
    )
    if not success:
        print(f"❌ 推送 tag 失败: {output}")
        print(f"提示: 可以稍后手动推送: git push origin {tag_name}")
        sys.exit(1)

    print("✓ 推送 tag 完成！")
    print("")
    print("✓ 自动提交 + 版本备份完成")
    print(f"Tag: {tag_name}")


if __name__ == "__main__":
    main()
