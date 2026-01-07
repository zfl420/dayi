#!/usr/bin/env python3
"""
Git Tag Agent - 自动创建版本备份 tag
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


def has_uncommitted_changes():
    """检查是否有未提交的修改"""
    success, output = run_command(
        'git status --porcelain',
        "检查 git 状态"
    )
    if not success:
        return False

    # 如果有输出，说明有未提交的修改
    return len(output.strip()) > 0


def commit_changes(version):
    """自动提交未提交的修改"""
    print("📝 检测到未提交的修改，正在自动提交...")

    # 添加所有修改
    success, output = run_command(
        'git add .',
        "添加修改到暂存区"
    )

    if not success:
        print(f"❌ 添加文件失败: {output}")
        return False

    # 使用固定格式的提交信息
    commit_message = f"chore: 版本备份 v{version} - 自动提交"

    # 提交修改
    success, output = run_command(
        f'git commit -m "{commit_message}"',
        "提交修改"
    )

    if not success:
        print(f"❌ 提交失败: {output}")
        return False

    print("✓ 修改已自动提交")
    return True


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


def main():
    # 获取最新版本并递增
    latest_version = get_latest_version()
    new_version = increment_version(latest_version)

    # 检查并自动提交未提交的修改
    if has_uncommitted_changes():
        if not commit_changes(new_version):
            sys.exit(1)

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
    print("正在推送到远程仓库...")

    # 推送 tag 到远程
    success, output = run_command(
        f'git push origin {tag_name}',
        "推送 tag"
    )

    if not success:
        print(f"❌ 推送失败: {output}")
        print(f"提示: 可以稍后手动推送: git push origin {tag_name}")
        sys.exit(1)

    print("推送完成！")
    print("")
    print("✓ 版本备份完成")
    print(f"Tag: {tag_name}")


if __name__ == "__main__":
    main()
