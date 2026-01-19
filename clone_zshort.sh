#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="/zserver/lib/"

process_repo() {
  local repo="$1"

  repo="${repo%.git}"

  local relative_path
  relative_path="$(echo "$repo" | sed -n 's#.*://[^/]*/zmedia/##p')"

  if [[ -z "$relative_path" ]]; then
    echo "⚠️  Skip invalid repo: $repo"
    return
  fi

  local target_dir="$ROOT_DIR/$relative_path"
  local parent_dir
  parent_dir="$(dirname "$target_dir")"

  if [[ -d "$target_dir" ]]; then
    echo "⏭  Skip (already exists): $target_dir"
    return
  fi

  echo "📥 Cloning $repo.git -> $target_dir"
  mkdir -p "$parent_dir"
  git clone "$repo.git" "$target_dir"
}

if [[ -t 0 && $# -eq 0 ]]; then
  echo "❌ No input. Provide a file or pipe URLs."
  exit 1
fi

if [[ $# -gt 0 ]]; then
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    process_repo "$line"
  done < "$1"
else
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    process_repo "$line"
  done
fi

echo "✅ Done"
