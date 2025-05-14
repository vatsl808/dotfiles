#!/bin/bash

# Ensure Hyprland environment variables are set
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-0}
export HYPRLAND_INSTANCE_SIGNATURE=${HYPRLAND_INSTANCE_SIGNATURE:-$(ls -t /run/user/$UID/hypr | head -n1)}

# Wallpaper directory
WALLPAPER_DIR=/home/vatsal/wallpaper

# Select a random wallpaper
WALLPAPER=$(realpath "$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | shuf -n 1)")

# Exit if no wallpaper found
if [ -z "$WALLPAPER" ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Ensure hyprpaper is running
pgrep hyprpaper || hyprpaper &

sleep 0.5

# Update hyprpaper
hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper "eDP-1,$WALLPAPER"
