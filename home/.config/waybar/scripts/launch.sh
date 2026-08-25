#!/usr/bin/env bash
# `exec_always waybar` can leave a previous instance running on reload.
# Clear it first so we don't end up with two bars.

pkill -x waybar 2>/dev/null

for _ in $(seq 1 20); do
    pgrep -x waybar >/dev/null || break
    sleep 0.1
done

exec waybar
