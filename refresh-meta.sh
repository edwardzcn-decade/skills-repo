#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$ROOT/meta.yaml"
NOW="$(TZ=UTC date '+%Y-%m-%dT%H:%M:%S+0000')"

stat_time() {
  local mode="$1"
  local target="$2"
  if stat -f '%SB' -t '%Y-%m-%dT%H:%M:%S%z' "$target" >/dev/null 2>&1; then
    if [[ "$mode" == "created" ]]; then
      TZ=UTC stat -f '%SB' -t '%Y-%m-%dT%H:%M:%S+0000' "$target"
    else
      TZ=UTC stat -f '%Sm' -t '%Y-%m-%dT%H:%M:%S+0000' "$target"
    fi
  else
    if [[ "$mode" == "created" ]]; then
      TZ=UTC stat -c '%w' "$target"
    else
      TZ=UTC stat -c '%y' "$target"
    fi | cut -d'.' -f1 | tr ' ' 'T'
  fi
}

frontmatter_value() {
  local file="$1"
  local key="$2"
  awk -v key="$key" '
    BEGIN { in_block = 0 }
    /^---$/ {
      if (in_block == 0) { in_block = 1; next }
      else { exit }
    }
    in_block == 1 {
      if ($0 ~ "^" key ":[[:space:]]*") {
        sub("^" key ":[[:space:]]*", "", $0)
        gsub(/^"|"$/, "", $0)
        print $0
        exit
      }
    }
  ' "$file"
}

yaml_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

emit_tags() {
  local dir="$1"
  IFS='-' read -r -a parts <<< "$dir"
  echo "    tags:"
  for part in "${parts[@]}"; do
    echo "      - $part"
  done
}

{
  echo "repo:"
  echo "  name: codex-skills"
  echo "  activation: \"Clone or pull this repository into ~/.codex/skills. Codex discovers skills from subdirectories containing SKILL.md automatically.\""
  echo "  generated_at: $NOW"
  echo "  ignored_paths:"
  echo "    - .system/"
  echo "    - codex-primary-runtime/"
  echo "skills:"

  while IFS= read -r -d '' skill_md; do
    skill_dir_path="$(dirname "$skill_md")"
    skill_dir="$(basename "$skill_dir_path")"
    skill_name="$(frontmatter_value "$skill_md" name)"
    if [[ -z "$skill_name" ]]; then
      skill_name="$skill_dir"
    fi
    description="$(frontmatter_value "$skill_md" description)"
    created_at="$(stat_time created "$skill_dir_path")"
    updated_at="$(stat_time updated "$skill_dir_path")"
    echo "  - name: \"$(yaml_escape "$skill_name")\""
    echo "    path: \"$skill_dir/SKILL.md\""
    echo "    enable_path: \"~/.codex/skills/$skill_dir\""
    echo "    activation: \"Available automatically when this repository is present at ~/.codex/skills.\""
    echo "    created_at: \"$created_at\""
    echo "    updated_at: \"$updated_at\""
    emit_tags "$skill_dir"
    echo "    description: \"$(yaml_escape "$description")\""
    echo "    notes: \"\""
  done < <(find "$ROOT" -mindepth 2 -maxdepth 2 -name SKILL.md \
    -not -path "$ROOT/.system/*" \
    -not -path "$ROOT/codex-primary-runtime/*" \
    -print0 | sort -z)
} > "$OUT"
