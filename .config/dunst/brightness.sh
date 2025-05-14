#!/bin/bash

# Function to get current brightness percentage
function get_brightness {
    brightnessctl -d intel_backlight get
}

# Function to get max brightness
function get_max_brightness {
    brightnessctl -d intel_backlight max
}

# Function to send a notification with the brightness level
function send_notification {
    DIR=$(dirname "$0")
    brightness=$(get_brightness)
    max_brightness=$(get_max_brightness)

    # Calculate brightness percentage
    percent=$((brightness * 100 / max_brightness))

    # Set icon (make sure this exists, or use a different one)
    icon="/usr/share/icons/Faba/48x48/notifications/notification-display-brightness.svg"

    # Create a simple progress bar
    # bar=$(seq -s "─" $((percent / 5)) | sed 's/[0-9]//g')
    bar_length=15
    filled=$((percent * bar_length / 100))
    bar=$(printf "%-${bar_length}s" "$(seq -s "─" $filled | tr -d '[:digit:]')")

    # Send notification
    $DIR/notify-send.sh "$bar" -i "$icon" -t 2000 --replace=556
}

# Handle arguments
case $1 in
    up)
        brightnessctl -d intel_backlight set +10%
        send_notification
        ;;
    down)
        brightness=$(get_brightness)
        max_brightness=$(get_max_brightness)
        min_brightness=$((max_brightness / 10))  # 10% of max brightness

        # Decrease brightness only if it's greater than 10%
        if [ "$brightness" -gt "$min_brightness" ]; then
            brightnessctl -d intel_backlight set 10%-
            send_notification
        fi
        ;;
    *)
        echo "Usage: $0 {up|down}"
        exit 1
        ;;
esac
