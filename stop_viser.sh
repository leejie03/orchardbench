#!/usr/bin/env bash
set -euo pipefail

pid_file="$HOME/orchardbench/viser.pid"

if [[ ! -f "$pid_file" ]]; then
    printf 'Viser is not running (no PID file)\n'
    exit 0
fi

pid="$(<"$pid_file")"
if kill -0 "$pid" 2>/dev/null; then
    kill "$pid"
    printf 'Stopped OrchardBench Viser (PID %s)\n' "$pid"
else
    printf 'Viser process %s was not running\n' "$pid"
fi

rm -f "$pid_file"
