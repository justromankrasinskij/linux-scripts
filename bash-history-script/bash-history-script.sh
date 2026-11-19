#!/usr/bin/env bash
set -euo pipefail

HISTFILE="${1:-${HISTFILE:-$HOME/.bash_history}}"

if [[ ! -f "$HISTFILE" ]]; then
    echo "File not found: $HISTFILE" >&2
    exit 1
fi

tmp="$(mktemp)"

tac -- "$HISTFILE" \
    | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' \
    | awk 'NF && !seen[$0]++' \
    | tac > "$tmp"

mv -- "$tmp" "$HISTFILE"
