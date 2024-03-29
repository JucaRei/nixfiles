#!/usr/bin/env bash

# Cache file for holding the current wallpaper
cache_file="$HOME/.cache/current_wallpaper"
rasi_file="$HOME/.cache/current_wallpaper.rasi"

# Create cache file if not exists
if [ ! -f $cache_file ] ;then
    touch $cache_file
    echo "$HOME/Pictures/wallpapers/default.jpg" > "$cache_file"
fi

# Create rasi file if not exists
if [ ! -f $rasi_file ] ;then
    touch $rasi_file
    echo "* { current-image: url(\"$HOME/Pictures/wallpapers/default.jpg\", height); }" > "$rasi_file"
fi

current_wallpaper=$(cat "$cache_file")

case $1 in

    # Load wallpaper from .cache of last session
    "init")
        if [ -f $cache_file ]; then
            wal -q -i $current_wallpaper
        else
            wal -q -i ~/Pictures/wallpapers
        fi
    ;;

    # Select wallpaper with rofi
    "select")

        selected=$( find "$HOME/Pictures/wallpapers" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -exec basename {} \; | sort -R | while read rfile
        do
            echo -en "$rfile\x00icon\x1f$HOME/Pictures/wallpapers/${rfile}\n"
        done | rofi -dmenu -replace -config ~/.config/rofi/config-wallpaper.rasi)
        if [ ! "$selected" ]; then
            echo "No wallpaper selected"
            exit
        fi
        wal -q -i ~/Pictures/wallpapers/$selected
    ;;

    # Randomly select wallpaper
    *)
        wal -q -i ~/Pictures/wallpapers/
    ;;

esac

# -----------------------------------------------------
# Load current pywal color scheme
# -----------------------------------------------------
source "$HOME/.cache/wal/colors.sh"
echo "Wallpaper: $wallpaper"

# -----------------------------------------------------
# Write selected wallpaper into .cache files
# -----------------------------------------------------
echo "$wallpaper" > "$cache_file"
echo "* { current-image: url(\"$wallpaper\", height); }" > "$rasi_file"

# -----------------------------------------------------
# get wallpaper image name
# -----------------------------------------------------
newwall=$(echo $wallpaper | sed "s|$HOME/Pictures/wallpapers/||g")

# -----------------------------------------------------
# Reload waybar with new colors
# -----------------------------------------------------
#~/dotfiles/waybar/launch.sh
killall .waybar-wrapped
sleep 0.2
waybar > /dev/null 2>&1 &
# -----------------------
------------------------------
# Set the new wallpaper
# -----------------------------------------------------
transition_type="wipe"
# transition_type="outer"
# transition_type="random"

swww img $wallpaper \
    --transition-bezier .43,1.19,1,.4 \
    --transition-fps=60 \
    --transition-type=$transition_type \
    --transition-duration=0.7 \
    --transition-pos "$( hyprctl cursorpos )"

# -----------------------------------------------------
# Send notification
# -----------------------------------------------------
sleep 1
notify-send "Colors and Wallpaper updated" "with image $newwall"

echo "DONE!"
