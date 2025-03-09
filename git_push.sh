#!/bin/bash
set -e

git add .

# 获取暂存区文件列表并生成提交信息
commit_msg=""
while read -r file; do
  dir=$(dirname "$file")          # 获取文件目录路径
  last_dir=$(basename "$dir")     # 获取最后一级目录名
  commit_msg+="$file $last_dir "  # 拼接为"文件路径 文件夹"
done < <(git diff --cached --name-only)

# 检查是否有变更文件
if [ -n "$commit_msg" ]; then
  # 提交变更并推送
  git commit -m "$commit_msg"
  git push -u origin main
else
  echo "没有检测到文件变更，跳过提交"
fi
