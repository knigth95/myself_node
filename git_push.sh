#!/bin/bash
set -e

# 获取所有变更文件（包括未跟踪文件）
declare -A dir_files
while read -r status file; do
  dir=$(dirname "$file")
  last_dir=$(basename "$dir")
  # 处理根目录显示为root
  [[ "$last_dir" == "." ]] && last_dir="root" 
  dir_files["$dir"]+="$file $last_dir "
done < <(git status --porcelain -z | xargs -0 -n2)

# 分批次处理每个文件夹
for dir in "${!dir_files[@]}"; do
  # 重置暂存区
  git reset > /dev/null 2>&1 || true

  # 添加当前文件夹下的所有变更
  while read -r file; do
    git add "$file"
  done <<< "$(echo ${dir_files[$dir]} | awk '{for(i=1;i<=NF;i+=2) print $i}')"

  # 生成提交信息
  commit_msg=""
  while read -r info; do
    commit_msg+="$info "
  done <<< "$(echo ${dir_files[$dir]} | awk '{for(i=1;i<=NF;i+=2) print $i, $(i+1)}')"

  # 提交并推送
  if [ -n "$commit_msg" ]; then
    git commit -m "$commit_msg" && git push -u origin main
  fi
done
