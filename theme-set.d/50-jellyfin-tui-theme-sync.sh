#!/bin/bash
# Sync jellyfin-tui Omarchy theme from Omarchy (kitty) colors
# Called by theme-set hook

KITTY_CONF="$HOME/.config/omarchy/current/theme/kitty.conf"
JELLYFIN_CONF="$HOME/.config/jellyfin-tui/config.yaml"

[[ ! -f "$KITTY_CONF" ]] && exit 0
[[ ! -f "$JELLYFIN_CONF" ]] && exit 0

# Extract colors from kitty.conf
get_color() { grep "^${1}\s" "$KITTY_CONF" | awk '{print $2}'; }
accent=$(get_color color2)
focus=$(get_color color4)
[[ -z "$focus" || -z "$accent" ]] && exit 0

tmpfile="${JELLYFIN_CONF}.tmp"

# Flags
has_themes=false
has_auto_color=false
has_omarchy=false

# Check current config for existing values
while IFS= read -r line; do
    trimmed="${line#"${line%%[![:space:]]*}"}"
    [[ "$trimmed" == themes:* ]] && has_themes=true
    [[ "$trimmed" =~ ^auto_color:\ (true|false)$ ]] && has_auto_color=true
    [[ "$trimmed" == '- name: "Omarchy"' ]] && has_omarchy=true
done < "$JELLYFIN_CONF"

# Build new file
> "$tmpfile"

insert_auto_color=false
insert_omarchy=false

while IFS= read -r line; do
    trimmed="${line#"${line%%[![:space:]]*}"}"

    # Skip existing auto_color (we'll insert/update later)
    if [[ "$trimmed" =~ ^auto_color:\ (true|false)$ ]]; then
        [[ "$has_auto_color" == true ]] && echo "auto_color: false" >> "$tmpfile"
        continue
    fi

    # Detect themes line
    if [[ "$trimmed" == themes:* ]]; then
        # Insert auto_color above themes if missing
        if [[ "$has_auto_color" == false ]]; then
            echo "auto_color: false" >> "$tmpfile"
            has_auto_color=true
        fi
        echo "$line" >> "$tmpfile"

        # Insert Omarchy theme if missing
        if [[ "$has_omarchy" == false ]]; then
            cat <<EOF >> "$tmpfile"
  - name: "Omarchy"
    base: "Dark"

    # remove background
    background: "none"

    border: "white"
    border_focused: "$focus"
    tab_active_foreground: "$focus"
    tab_inactive_foreground: "white"

    progress_fill: "$accent"
    accent: "$accent"

EOF
            has_omarchy=true
        fi
        continue
    fi

    # Detect Omarchy theme block start
    if [[ "$trimmed" == '- name: "Omarchy"' ]]; then
        echo "$line" >> "$tmpfile"
        in_omarchy=true
        continue
    fi

    # Update Omarchy colors if inside block
    if [[ "$in_omarchy" == true ]]; then
        case "$trimmed" in
            border_focused:*) echo "    border_focused: \"$focus\"" >> "$tmpfile" ;;
            tab_active_foreground:*) echo "    tab_active_foreground: \"$focus\"" >> "$tmpfile" ;;
            progress_fill:*) echo "    progress_fill: \"$accent\"" >> "$tmpfile" ;;
            accent:*) echo "    accent: \"$accent\"" >> "$tmpfile" ;;
            -*) in_omarchy=false; echo "$line" >> "$tmpfile" ;; # another theme starts
            *) echo "$line" >> "$tmpfile" ;;
        esac
        continue
    fi

    # Default: copy line
    echo "$line" >> "$tmpfile"
done < "$JELLYFIN_CONF"

# If themes: didn't exist at all, create it at the end
if [[ "$has_themes" == false ]]; then
    [[ "$has_auto_color" == false ]] && echo "auto_color: false" >> "$tmpfile"
    echo "themes:" >> "$tmpfile"
    cat <<EOF >> "$tmpfile"
  - name: "Omarchy"
    base: "Dark"

    # remove background
    background: "none"

    border: "white"
    border_focused: "$focus"
    tab_active_foreground: "$focus"
    tab_inactive_foreground: "white"

    progress_fill: "$accent"
    accent: "$accent"
EOF
fi

mv "$tmpfile" "$JELLYFIN_CONF"
