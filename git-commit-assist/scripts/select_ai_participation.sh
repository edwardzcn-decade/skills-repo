#!/usr/bin/env bash

set -euo pipefail

print_menu() {
  cat <<'EOF'
Select the AI participation level for this commit:
1. AI-Originated  - AI completed nearly all work; human reviewed.
2. AI-Implemented - Human planned; AI implemented most changes.
3. Human-Led      - Human led; AI assisted with coding.
4. Human-Only     - No AI contribution.
EOF
}

codes=(
  "ai-originated"
  "ai-implemented"
  "human-led"
  "human-only"
)

labels=(
  "AI-Originated"
  "AI-Implemented"
  "Human-Led"
  "Human-Only"
)

summaries=(
  "AI produced nearly all implementation content; human reviewed only."
  "Human supplied the plan; AI implemented most changes; human made minor edits."
  "Human led the implementation; AI assisted with coding."
  "No AI contribution."
)

needs_coauthor=(1 1 1 0)

emit_selection() {
  local choice="$1"

  case "${choice}" in
    1|2|3|4)
      local index=$((choice - 1))
      printf 'ai_participation_code=%s\n' "${codes[$index]}"
      printf 'ai_participation_label=%s\n' "${labels[$index]}"
      printf 'ai_participation_summary=%s\n' "${summaries[$index]}"
      printf 'needs_coauthor=%s\n' "${needs_coauthor[$index]}"
      ;;
    *)
      printf "Invalid selection. Please enter 1, 2, 3, or 4.\n" >&2
      return 1
      ;;
  esac
}

case "${1:-}" in
  --menu)
    print_menu
    exit 0
    ;;
  --choice)
    if [[ $# -ne 2 ]]; then
      printf "Usage: %s [--menu | --choice <1-4> | --interactive]\n" "$0" >&2
      exit 1
    fi
    emit_selection "$2"
    exit 0
    ;;
  --interactive)
    print_menu
    while true; do
      printf "Enter 1-4: "
      IFS= read -r choice
      if emit_selection "$choice"; then
        exit 0
      fi
    done
    ;;
  "")
    printf "Usage: %s [--menu | --choice <1-4> | --interactive]\n" "$0" >&2
    exit 1
    ;;
  *)
    printf "Unknown argument: %s\n" "$1" >&2
    exit 1
    ;;
esac
