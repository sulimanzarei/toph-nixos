# toph-theme: wallpaper and colours for my Hyprland session.
#
#   toph-theme wall [FILE]   set FILE as wallpaper, or a random one from the folder
#   toph-theme signature     colours from my signature blue
#   toph-theme dynamic       colours from the current wallpaper
#   toph-theme toggle        switch between signature and dynamic
#   toph-theme apply         regenerate colours for the current state
#   toph-theme status        show the current wallpaper and colour mode
#
# Wallpapers: awww draws them, with a circle that grows from the mouse pointer.
# Colours: matugen turns one source colour into a full palette and writes it into
# the templates listed in ~/.config/matugen/config.toml (Hyprland, kitty).
#
# Nix builds this file into a command with writeShellApplication, which adds
# `set -euo pipefail` and checks it with shellcheck at build time.

SIGNATURE="#0d73cc"   # kitty's default blue, the colour of my name in fastfetch
WALLDIR="${TOPH_WALLPAPERS:-$HOME/Pictures/Wallpapers}"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/toph"
mkdir -p "$STATE"

current_wall() { cat "$STATE/wallpaper" 2>/dev/null || true; }
current_mode() { cat "$STATE/mode" 2>/dev/null || echo signature; }

# Build the palette and fill the templates. scheme-content keeps the source
# colour itself as one of the palette colours instead of washing it out.
recolour() {
    local mode wall
    mode="$(current_mode)"
    wall="$(current_wall)"
    if [[ "$mode" == dynamic && -f "$wall" ]]; then
        # --source-color-index 0: take the most dominant colour without asking
        # (matugen 4 otherwise shows an interactive picker, which hangs a script)
        matugen image "$wall" --mode dark --type scheme-content \
            --source-color-index 0 --fallback-color "$SIGNATURE" --quiet
    else
        matugen color hex "$SIGNATURE" --mode dark --type scheme-content --quiet
    fi
}

# Draw the wallpaper on every screen. The circle grows from the mouse pointer;
# on the other screen it starts from the point nearest the pointer, so the two
# circles look like one shape crossing the gap.
draw() {
    local file="$1" cx cy name mx my w h lx ly
    if ! awww query >/dev/null 2>&1; then
        echo "toph-theme: awww-daemon is not running (it starts with Hyprland)" >&2
        exit 1
    fi
    read -r cx cy < <(hyprctl cursorpos | tr -d ',')
    while read -r name mx my w h; do
        lx=$(( cx < mx ? 0 : (cx >= mx + w ? w - 1 : cx - mx) ))
        ly=$(( cy < my ? 0 : (cy >= my + h ? h - 1 : cy - my) ))
        # awww measures pixel positions from the bottom-left corner
        awww img "$file" --outputs "$name" \
            --transition-type grow --transition-pos "$lx,$(( h - ly ))" \
            --transition-duration 1.2 --transition-fps 240 &
    done < <(hyprctl monitors -j | jq -r '.[] | "\(.name) \(.x) \(.y) \(.width) \(.height)"')
    wait
}

pick_random() {
    local now
    now="$(current_wall)"
    find -L "$WALLDIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \) \
        ! -path "$now" | shuf -n 1
}

case "${1:-status}" in
    wall)
        file="${2:-$(pick_random)}"
        if [[ -z "$file" || ! -f "$file" ]]; then
            echo "toph-theme: no wallpaper found (looked in $WALLDIR)" >&2
            exit 1
        fi
        file="$(realpath "$file")"
        echo "$file" > "$STATE/wallpaper"
        draw "$file"
        if [[ "$(current_mode)" == dynamic ]]; then recolour; fi
        ;;
    signature | dynamic)
        echo "$1" > "$STATE/mode"
        recolour
        ;;
    toggle)
        if [[ "$(current_mode)" == signature ]]; then next=dynamic; else next=signature; fi
        echo "$next" > "$STATE/mode"
        recolour
        ;;
    apply)
        recolour
        ;;
    status)
        echo "wallpaper: $(current_wall)"
        echo "colours:   $(current_mode)"
        ;;
    *)
        echo "usage: toph-theme wall [FILE] | signature | dynamic | toggle | apply | status" >&2
        exit 2
        ;;
esac
