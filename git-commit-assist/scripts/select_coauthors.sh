#!/usr/bin/env bash

set -euo pipefail

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

selected=()

while true; do
  printf "Enter choices: "
  IFS= read -r raw_choices

  if [[ -z "${raw_choices// }" || "${raw_choices// }" == "0" ]]; then
    exit 0
  fi

  IFS=',' read -r -a choices <<<"$raw_choices"
  invalid=0
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
          invalid=1
          break
        fi
        append_unique "$custom_partner"
        ;;
      0)
        ;;
      *)
        printf "Invalid selection: %s\n" "$choice" >&2
        invalid=1
        break
        ;;
    esac
  done

  if [[ "$invalid" -eq 0 ]]; then
    for partner in "${selected[@]}"; do
      printf 'coauthored_by=%s\n' "$partner"
    done
    exit 0
  fi
done
