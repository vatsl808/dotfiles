#!/bin/bash

# Define the list of wallpapers
wallpapers=(
    "/home/vatsal/Pictures/platforms.png"
    "/home/vatsal/Pictures/gruvbox_room.png"
    "/home/vatsal/Pictures/australia.jpg"
    "/home/vatsal/Pictures/straw_hat.jpg"
    "/home/vatsal/Pictures/shougan_castle.png"
)

# Choose a random wallpaper from the list
random_wallpaper="${wallpapers[$((RANDOM % ${#wallpapers[@]}))]}"

hyprctl hyprpaper preload "$random_wallpaper"

# Update the wallpaper using hyprctl
hyprctl hyprpaper wallpaper "eDP-1,$random_wallpaper"
