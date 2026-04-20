---
name: host-status
description: Inspect the current host machine's operating system, uptime, CPU and memory pressure, disk usage, network summary, and high-load processes using simple local shell commands. Use when the user asks for host status, system overview, machine health, resource pressure, load, or a quick runtime diagnosis of the current Codex Desktop host.
---

# Host Status

## Overview

Use this skill to gather a concise but useful snapshot of the current host machine. Run the bundled shell script first, then summarize the results in plain language with the most important pressure points, anomalies, and caveats.

## Workflow

1. Run `scripts/host_status.sh`.
2. Read the script output instead of guessing.
3. Report the host operating system and machine basics first.
4. Report current pressure indicators next:
   - uptime and load
   - CPU summary
   - memory pressure or free memory
   - disk usage
   - network summary when available
   - top processes by CPU and memory
5. If the output contains unsupported-command fallbacks, say so briefly rather than pretending the missing section was measured directly.

## Output Guidance

Prefer a short status summary followed by a compact list of concrete findings.

Call out:

- whether the machine appears healthy or under pressure
- any obviously constrained resource
- any unusually heavy process
- any missing metrics caused by platform differences

Do not over-interpret transient load from a single sample. Treat the script output as a point-in-time snapshot.

## Script

Run:

```bash
bash ~/.codex/skills/host-status/scripts/host_status.sh
```

The script is written to work well on macOS first and to fall back to common Unix tools when possible.
