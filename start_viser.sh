#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

log_file="$HOME/orchardbench/viser.log"
pid_file="$HOME/orchardbench/viser.pid"

if [[ -f "$pid_file" ]] && kill -0 "$(<"$pid_file")" 2>/dev/null; then
    printf 'Viser is already running (PID %s)\n' "$(<"$pid_file")"
    exit 0
fi

nohup pixi run python scripts/grow_tree.py \
    --auto --foliage --break --viewer viser \
    >"$log_file" 2>&1 &

pid=$!
printf '%s\n' "$pid" >"$pid_file"
printf 'Log: %s\n' "$log_file"

printf 'Starting OrchardBench Viser (PID %s)...\n' "$pid"
printf 'Following startup output from %s\n\n' "$log_file"
tail -f "$log_file" &
tail_pid=$!
trap 'kill "$tail_pid" 2>/dev/null || true' EXIT

while true; do
    if curl -s --max-time 2 http://localhost:8080 >/dev/null 2>&1; then
        kill "$tail_pid" 2>/dev/null || true
        printf 'OrchardBench is ready.\n'
        break
    fi
    if ! kill -0 "$pid" 2>/dev/null; then
        kill "$tail_pid" 2>/dev/null || true
        printf 'OrchardBench exited before Viser became ready.\n' >&2
        printf 'See %s\n' "$log_file" >&2
        rm -f "$pid_file"
        exit 1
    fi
    sleep 2
done

printf '\nOn your laptop, first create the SSH tunnel:\n'
printf '  ssh -N -L 8080:localhost:8080 its-server-2\n'
printf 'Then open this URL in your browser:\n'
printf '  http://localhost:8080\n'
