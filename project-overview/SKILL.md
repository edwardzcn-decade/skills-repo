---
name: project-overview
description: Scan one or more project directories, read project-authored readable files, infer project purpose and future direction from repository evidence, and write canonical project memories into ~/.codex/memories using the user's naming conventions. Use this when the user requests project overview memory generation, repository/project summarization, or commands such as /project-overview <project_name> [other_project_names].
---

# Project Overview

## Overview

Use this skill when the user wants a project overview memory built or refreshed.

## Expected invocation shape

Typical user form:

- `/project-overview <project_name>`
- `/project-overview <project_name> <other_project_name> ...`
- `/project-overview <project_name> --languages en`
- `/project-overview <project_name> --languages en zh`

Interpret `--languages` as an optional list of output language codes.

Default behavior:
- if `--languages` is omitted, generate English output only
- if `--languages` is provided, generate one memory file per requested language

Treat each argument as a target directory basename to locate under `~/` unless the user provides an explicit path.

## Required workflow

1. Parse optional `--languages` arguments.
   - treat language codes as ordered output targets
   - default to `en` when omitted
   - deduplicate while preserving order
2. Read current user memory conventions first:
   - `~/.codex/memories/user-level-memory-conventions.md`
3. Search `~/` for each requested project directory by exact basename first.
4. If exact lookup fails, optionally do a cautious wildcard follow-up search for closely related names.
5. For each found project:
   - read project-authored readable files
   - exclude vendored/generated/build directories unless the user explicitly asks otherwise
   - examples to exclude by default: `.git`, `node_modules`, `target`, `dist`, `build`, `.wrangler`, `.next`, binary assets
6. Collect factual evidence:
   - directory basename
   - formal project name
   - languages
   - frameworks / core technical keywords
   - latest repo commit if inside a git repo
   - latest observed file write time among project-authored files
   - latest observed file access time among project-authored files
   - current working tree status if meaningful
7. Write a memory file into `~/.codex/memories`.
8. If a requested project is not found, still write a lookup memory recording the miss explicitly.

## Required memory contents

Each project memory should include at minimum:

- project identity
- stack and core terms
- time signals
- medium-length project summary based on source reading
- medium-length future direction / expected plan with evidence
- evidence and reading basis

Separate factual evidence from inference. Do not claim certainty where only inference is available.

## Canonical naming rule

Use the user-level canonical file naming rule from:
- `~/.codex/memories/user-level-memory-conventions.md`

Current valid forms are:

- `A-B-C.md`
- `A-B-C-D.md`

Interpretation:

- `A` = exact project directory basename
- `B` = memory category such as `overview`, `lookup`, `goals`, `plans`, `handoff`
- `C` = date in `YYYY-MM-DD`
- `D` = optional language code such as `en`, `zh`, `fr`

Default language-aware behavior:
- default language is `en`
- if the requested output language set is exactly `en`, prefer `A-B-C.md` for backward compatibility unless the user explicitly requests language-tagged filenames
- if multiple languages are requested, use `A-B-C-D.md` for each generated file
- `D` must be the language code of that file, for example `en`, `zh`, or `fr`

For this skill, default category is:
- found project: `overview`
- missing project: `lookup`

## Reading discipline

Read enough source to support a serious summary.
Prefer project-authored files such as:

- `README*`
- `package.json`
- `Cargo.toml`
- `pyproject.toml`
- `go.mod`
- `wrangler.*`
- key files under `src/`, `server/`, `app/`, `client/`, `routes/`
- test files when they reveal intent
- contributing / roadmap / planning docs

Do not summarize dependency trees as if they were authored project intent.

## Output discipline

Write memory files under `~/.codex/memories/`.
Keep them useful for future agents:
- concise but not shallow
- explicit about evidence
- explicit about missing data
- explicit when a “future direction” section is inferred rather than stated

If multiple languages are requested:
- generate one standalone memory file per language
- keep section structure and factual content aligned across language versions
- translate prose, but preserve identifiers, file paths, timestamps, commit hashes, branch names, and code symbols exactly
- do not mix multiple languages in the same memory file unless the user explicitly asks for bilingual inline output
- if one requested language cannot be produced reliably, record that failure explicitly rather than silently skipping it
