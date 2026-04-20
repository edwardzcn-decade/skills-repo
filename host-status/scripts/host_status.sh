#!/usr/bin/env bash
set -euo pipefail

section() {
  printf '\n== %s ==\n' "$1"
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

section "Timestamp"
date '+%Y-%m-%d %H:%M:%S %Z'

section "System"
uname -a || true
if has_cmd sw_vers; then
  sw_vers || true
fi
if has_cmd system_profiler; then
  system_profiler SPHardwareDataType 2>/dev/null | sed -n '1,20p' || true
fi

section "Uptime and Load"
uptime || true
if has_cmd sysctl; then
  sysctl -n vm.loadavg 2>/dev/null || true
fi

section "CPU"
if has_cmd top; then
  cpu_output="$(top -l 1 -n 0 2>/dev/null | sed -n '/^CPU usage:/p;/^Load Avg:/p' || true)"
  if [ -n "${cpu_output}" ]; then
    printf '%s\n' "${cpu_output}"
  else
    echo "[unavailable] top output is not accessible in the current runtime"
  fi
else
  echo "[unavailable] top command not found"
fi
if has_cmd sysctl; then
  sysctl -n machdep.cpu.brand_string 2>/dev/null || true
  sysctl -n hw.logicalcpu 2>/dev/null | awk '{print "logical_cpu: " $0}' || true
  sysctl -n hw.physicalcpu 2>/dev/null | awk '{print "physical_cpu: " $0}' || true
fi

section "Memory"
if has_cmd memory_pressure; then
  memory_pressure 2>/dev/null | sed -n '1,20p' || true
fi
if has_cmd vm_stat; then
  vm_stat 2>/dev/null | sed -n '1,20p' || true
fi
if has_cmd top; then
  top -l 1 -n 0 2>/dev/null | sed -n '/^PhysMem:/p;/^VM:/p' || true
fi

section "Disk"
df -h / 2>/dev/null || true
df -h 2>/dev/null | sed -n '1,12p' || true

section "Network"
if has_cmd ifconfig; then
  ifconfig 2>/dev/null | sed -n '1,80p' || true
fi
if has_cmd netstat; then
  netstat -rn 2>/dev/null | sed -n '1,40p' || true
fi

section "Top Processes By CPU"
cpu_ps_output="$(ps -Ao pid,ppid,%cpu,%mem,state,comm -r 2>/dev/null | sed -n '1,12p' || true)"
if [ -n "${cpu_ps_output}" ]; then
  printf '%s\n' "${cpu_ps_output}"
else
  echo "[unavailable] ps output is not accessible in the current runtime"
fi

section "Top Processes By Memory"
mem_ps_output="$(ps -Ao pid,ppid,%mem,%cpu,state,comm -m 2>/dev/null | sed -n '1,12p' || true)"
if [ -n "${mem_ps_output}" ]; then
  printf '%s\n' "${mem_ps_output}"
else
  echo "[unavailable] ps output is not accessible in the current runtime"
fi
