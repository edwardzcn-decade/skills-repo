---
name: git-commit-assist
description: Draft Angular-style git commit messages and complete git commit workflows with explicit AI participation metadata. Use when the user asks to create a commit, says "git commit", "commit this", "write a commit message", "will commit" in English or Chinese, or needs to choose AI attribution and Co-authored-by (coauthor) trailers for a commit.
---

# Git Commit Assist

## Overview

Use this skill when a change is ready to commit and the user wants help drafting the message or finishing the commit. Read the relevant diff, draft the commit message with the model, then collect AI participation and co-author metadata through local scripts to avoid unnecessary token use.

## Fixed AI Participation Levels

Keep these four level names fixed:

- `AI-Originated`: AI defined the solution and implemented most of it; human provided high-level prompts and made light review/editing.
- `AI-Implemented`: Human defined and supplied the plan; AI implemented most of it; human made minor review/editing.
- `Human-Led`: human led the implementation; AI assisted with coding work.
- `Human-Only`: no AI contribution. Skip co-author selection.

Do not ask the user to rename, reinterpret, or free-form these levels. Use the local selector script instead of spending model tokens on this choice.

## Workflow

1. Inspect the candidate commit with `git status --short`, `git diff --cached --stat`, and the relevant diff.
2. Prefer staged changes when staged files exist. Do not stage or unstage files unless the user asks.
3. Draft an Angular-style subject line as `<type>(optional-scope): summary`.
4. Pick the `type` from the actual change. Prefer `feat`, `fix`, `refactor`, `docs`, `test`, `build`, `ci`, `perf`, `style`, or `chore`.
5. Keep the subject brief, imperative, and without a trailing period.
6. Add a body only when it improves clarity. Keep every body line to 20 words or fewer.
7. Run `bash scripts/select_ai_participation.sh` in a local shell and read its machine-readable output.
8. If the selected participation level is not `Human-Only`, run `bash scripts/select_coauthors.sh` in a local shell.
9. Append trailers after one blank line. Use exactly `Co-authored-by: Name <email>`.
10. If the user explicitly asked to complete the commit, show the final message briefly and run `git commit` with that message. Otherwise stop after presenting the message.

## Commit Message Rules

- Use Angular conventions, not free-form prose.
- Infer an optional scope only when the diff has a clear bounded area.
- Prefer no body over filler text.
- Keep each body line under or equal to 20 words.
- Separate trailers from the body with a single blank line.
- Use one `Co-authored-by:` line per selected partner.

Example structure:

```text
feat(parser): support nested config overrides

Handle nested keys during merge.
Preserve explicit null removals.

Co-authored-by: OpenAI Codex <codex@openai.com>
Co-authored-by: Claude Sonnet <claude@anthropic.com>
```

## Local Scripts

### scripts/select_ai_participation.sh

Run this script locally instead of asking the user in chat. It presents the fixed four-level menu and prints machine-readable lines:

```text
ai_participation_code=human-led
ai_participation_label=Human-Led
ai_participation_summary=Human led the implementation; AI assisted with coding.
needs_coauthor=1
```

Treat `needs_coauthor=0` as a hard stop for co-author selection.

### scripts/select_coauthors.sh

Run this script only when `needs_coauthor=1`. It presents local menu choices and prints one line per selected partner:

```text
coauthored_by=OpenAI Codex <codex@openai.com>
coauthored_by=Claude Sonnet <claude@anthropic.com>
```

Supported built-in partners:

- `OpenAI Codex <codex@openai.com>`
- `Claude Sonnet <claude@anthropic.com>`
- `GitHub Copilot <copilot@github.com>`
- `Gemini <gemini@google.com>`
- `Custom...`

When `Custom...` is selected, require the user to enter `Name <email>` and preserve the exact value if it is valid.

## Notes

- Do not emit `Co-authored-by:` trailers for `Human-Only`.
- Do not invent co-authors that the local script did not return.
- If the user wants only a draft, stop before `git commit`.
- If the user wants the commit executed, make sure the final message includes the trailers before committing.
