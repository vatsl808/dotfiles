#!/bin/bash

# You can call this script like this:
# $ ./volume.sh up
# $ ./volume.sh down
# $ ./volume.sh mute

function get_volume {
    volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
    if [ "$volume" -gt 100 ]; then
        echo 100
    else
        echo "$volume"
    fi
}

function is_mute {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED
}

function send_notification {
    DIR=`dirname "$0"`
    volume=`get_volume`

    if [ "$volume" -gt 100 ]; then
        volume=100
    fi
    
    if is_mute; then
        icon_name="/usr/share/icons/Faba/48x48/notifications/notification-audio-volume-muted.svg"
        $DIR/notify-send.sh "Muted" -i "$icon_name" -t 2000 --replace=555
        return
    fi
    
    if [ "$volume" -eq 0 ]; then
        icon_name="/usr/share/icons/Faba/48x48/notifications/notification-audio-volume-muted.svg"
    elif [ "$volume" -lt 10 ]; then
        icon_name="/usr/share/icons/Faba/48x48/notifications/notification-audio-volume-low.svg"
    elif [ "$volume" -lt 30 ]; then
        icon_name="/usr/share/icons/Faba/48x48/notifications/notification-audio-volume-low.svg"
    elif [ "$volume" -lt 70 ]; then
        icon_name="/usr/share/icons/Faba/48x48/notifications/notification-audio-volume-medium.svg"
    else
        icon_name="/usr/share/icons/Faba/48x48/notifications/notification-audio-volume-high.svg"
    fi
    
    # echo $(get_volume)
    # bar=$(seq -s "─" $(($volume/5)) | sed 's/[0-9]//g')

    # $DIR/notify-send.sh $bar -i "$icon_name" -t 2000 --replace=555

    bar_length=15  # Max number of bar characters
    filled=$((volume * bar_length / 100))  # Scale volume to bar length
    bar=$(printf "%-${bar_length}s" "$(seq -s "─" $filled | tr -d '[:digit:]')")

    $DIR/notify-send.sh "$bar" -i "$icon_name" -t 2000 --replace=555

}

case $1 in
    up)
        current_volume=$(get_volume)
        if [ "$current_volume" -lt 100 ]; then
            wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
            wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+
        fi
        send_notification
        ;;
    down)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-
        send_notification
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        send_notification
        ;;
esac
