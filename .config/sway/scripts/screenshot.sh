#!/usr/bin/env bash
# Screenshot helper: capture a region, the focused window, or the focused
# output. Every capture goes to BOTH the clipboard and a file.
#
# Usage: screenshot.sh region|window|output
#
# Bound to Print / Shift+Print / Ctrl+Print in ~/.config/sway/config.
#
# Why a script rather than three bare `bindsym ... exec` lines: each mode needs
# a geometry computed first (slurp, or a jq query against the sway tree), the
# result has to be forked to two sinks, and a cancelled selection must exit
# quietly rather than writing a zero-byte file. That is more than an exec line
# can express.

set -uo pipefail

mode=${1:-region}

dir=$HOME/Pictures/Screenshots
mkdir -p "$dir"
# Colons are legal on ext4 but awkward to type unquoted, hence the dashes.
# Two captures inside the same second would otherwise collide and the second
# would silently overwrite the first, so disambiguate with a suffix.
stamp=$(date +%Y-%m-%d_%H-%M-%S)
file=$dir/$stamp.png
n=2
while [ -e "$file" ]; do
    file=$dir/$stamp-$n.png
    n=$((n + 1))
done

case $mode in
    region)
        # slurp exits non-zero on Escape / right-click; treat that as a cancel.
        geom=$(slurp) || exit 0
        [ -n "$geom" ] || exit 0
        label="Region"
        ;;
    window)
        # The focused node's rect is already in global compositor coordinates,
        # which is exactly what `grim -g` wants. `.. | select(...)` walks the
        # whole tree because focused windows can be nested arbitrarily deep.
        geom=$(swaymsg -t get_tree | jq -r '
            .. | objects
            | select(.focused? == true and .type? != "workspace")
            | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"' | head -1)
        [ -n "$geom" ] || { notify-send -u critical -a Screenshot "Screenshot failed" "No focused window."; exit 1; }
        label="Window"
        ;;
    output)
        # Whole-output capture is grim's -o (by name), not a -g geometry.
        name=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')
        [ -n "$name" ] || { notify-send -u critical -a Screenshot "Screenshot failed" "No focused output."; exit 1; }
        label="Output $name"
        ;;
    *)
        echo "usage: ${0##*/} region|window|output" >&2
        exit 2
        ;;
esac

# grim writes the PNG to stdout with `-`; tee lands it on disk. Splitting into
# a temp file and then wl-copy (rather than a second tee branch) keeps the
# failure check below simple -- wl-copy forks to own the selection, so its own
# exit status says nothing useful about whether the capture worked.
if [ "$mode" = output ]; then
    grim -o "$name" - | tee "$file" >/dev/null
else
    grim -g "$geom" - | tee "$file" >/dev/null
fi

# PIPESTATUS[0] is grim's status; a failed grim still leaves tee's success.
if [ "${PIPESTATUS[0]}" -ne 0 ] || [ ! -s "$file" ]; then
    rm -f "$file"
    notify-send -u critical -a Screenshot "Screenshot failed" "$label"
    exit 1
fi

wl-copy < "$file"

notify-send -a Screenshot "$label copied" "Saved to ${file/#$HOME/\~}"
