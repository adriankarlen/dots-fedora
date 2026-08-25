#!/usr/bin/env bash
# Opens lazyspotify on workspace 4 with cava tiled beneath it, taking the
# bottom 15%.
#
# This is a script rather than plain sway config because the layout has to be
# built in order: the second window only lands *below* the first if the first
# already exists and the container has been switched to a vertical split. sway
# has no way to express that sequencing declaratively, and ghostty cannot open
# a pre-split layout from the command line (there is no --split flag, and a
# split opened by keybind runs the default shell rather than a given command).
#
# Both terminals override adjust-cell-height from ~/.config/ghostty/config;
# the extra leading suits prose but loosens up box drawing and cava's bars.

set -u

ws=4
ls_id=com.mitchellh.ghostty.lazyspotify
cava_id=com.mitchellh.ghostty.cava
lazyspotify=/home/adk/.local/bin/lazyspotify

# ~/.local/bin is not on the PATH sway inherits, hence the absolute path above.
term=(ghostty --adjust-cell-height=0)

# True if a window with the given app_id exists anywhere in the tree.
have() {
    swaymsg -t get_tree | python3 -c '
import json, sys
want = sys.argv[1]
def walk(node):
    if node.get("app_id") == want:
        return True
    return any(walk(child)
               for key in ("nodes", "floating_nodes")
               for child in node.get(key, []))
sys.exit(0 if walk(json.load(sys.stdin)) else 1)' "$1"
}

# Windows appear asynchronously, so poll instead of guessing at a sleep.
wait_for() {
    for _ in $(seq 1 60); do
        have "$1" && return 0
        sleep 0.1
    done
    return 1
}

# Already up: just go to it rather than starting a second copy.
if have "$ls_id"; then
    exec swaymsg "workspace number $ws"
fi

swaymsg "workspace number $ws"

"${term[@]}" --class="$ls_id" -e "$lazyspotify" &
wait_for "$ls_id" || exit 1

# Stack the next window below the player instead of beside it.
swaymsg "[app_id=\"$ls_id\"] focus"
swaymsg splitv

"${term[@]}" --class="$cava_id" -e cava &
wait_for "$cava_id" || exit 1

# wait_for returns the moment the window maps, which can be marginally before
# ghostty has finished setting up; resizing into that gap has been seen to take
# cava down with it. A brief settle avoids the race.
sleep 0.3

# ppt is a percentage of the parent container, i.e. the workspace here.
swaymsg "[app_id=\"$cava_id\"] resize set height 15 ppt"

# Leave the player focused; cava is only there to be looked at.
swaymsg "[app_id=\"$ls_id\"] focus"
