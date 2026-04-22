#!/usr/bin/env bash

set -euo pipefail

print_menu() {
  cat <<'EOF'
Select Co-authored-by partners for this commit.
Enter comma-separated numbers. Use 0 for none.
1. OpenAI Codex <codex@openai.com>
2. Claude Sonnet <claude@anthropic.com>
3. GitHub Copilot <copilot@github.com>
4. Gemini <gemini@google.com>
5. Custom...
0. None
EOF
}

partners=(
  "OpenAI Codex <codex@openai.com>"
  "Claude Sonnet <claude@anthropic.com>"
  "GitHub Copilot <copilot@github.com>"
  "Gemini <gemini@google.com>"
)

is_valid_identity() {
  local value="$1"
  printf '%s\n' "$value" | grep -Eq '^[^<>][^<>]* <[^<>[:space:]]+@[^<>[:space:]]+>$'
}

append_unique() {
  local candidate="$1"
  local existing
  for existing in "${selected[@]:-}"; do
    if [[ "$existing" == "$candidate" ]]; then
      return 0
    fi
  done
  selected+=("$candidate")
}

emit_selection() {
  local raw_choices="$1"
  local normalized
  local choice
  local custom_index=0

  if [[ -z "${raw_choices// }" || "${raw_choices// }" == "0" ]]; then
    return 0
  fi

  IFS=',' read -r -a choices <<<"$raw_choices"
  selected=()

  for choice in "${choices[@]}"; do
    normalized="${choice//[[:space:]]/}"

    case "$normalized" in
      1|2|3|4)
        append_unique "${partners[$((normalized - 1))]}"
        ;;
      5)
        printf "Enter custom co-author as Name <email>: "
        IFS= read -r custom_partner
        if ! is_valid_identity "$custom_partner"; then
          printf "Invalid format. Expected Name <email>.\n" >&2
          return 1
        fi
        append_unique "$custom_partner"
        custom_index=$((custom_index + 1))
        ;;
      0)
        if [[ "${raw_choices//[[:space:]]/}" != "0" ]]; then
          printf "Invalid selection: %s\n" "$choice" >&2
          return 1
        fi
        ;;
      *)
        printf "Invalid selection: %s\n" "$choice" >&2
        return 1
        ;;
    esac
  done

  local partner
  for partner in "${selected[@]}"; do
    printf 'coauthored_by=%s\n' "$partner"
  done
}

case "${1:-}" in
  --menu)
    print_menu
    exit 0
    ;;
  --choice)
    if [[ $# -lt 2 ]]; then
      printf "Usage: %s [--menu | --choice <csv> | --interactive]\n" "$0" >&2
      exit 1
    fi
    emit_selection "$2"
    exit 0
    ;;
  --interactive)
    print_menu
    selected=()
    while true; do
      printf "Enter choices: "
      IFS= read -r raw_choices
      if emit_selection "$raw_choices"; then
        exit 0
      fi
    done
    ;;
  "")
    printf "Usage: %s [--menu | --choice <csv> | --interactive]\n" "$0" >&2
    exit 1
    ;;
  *)
    printf "Unknown argument: %s\n" "$1" >&2
    exit 1
    ;;
esac
