#!/usr/bin/env bash
#https://raw.githubusercontent.com/SuchithSridhar/nixos-dotfiles/60b591a3f0d93c65ef9d25eb36e3a4f121bb3fb2/scripts/power-controls
#
# Author: Suchith Sridhar
# Website: https://suchicodes.com/
#
# This script is used to manage power based controls on Hyprland
# These are operations like shutdown, lock, and logout.
#
# Before performing some of these operations we handle the closing of apps.
# If there are apps that can't be closed without losing data, then the power operation
# is cancelled and a notification about the cause of the cancellation is sent.

function close_apps() {
    BRAVE=$(hyprctl clients | grep -c "class: Brave-browser")
    CHROMIUM=$(hyprctl clients | grep -c "class: brave-browser")
    FIREFOX=$(hyprctl clients | grep -c "class: firefox")

    if [ "$BRAVE" -gt "1" ]; then
        notify-send "power controls" "Brave multiple windows open"
        exit 1
    elif [ "$CHROMIUM" -gt "1" ]; then
        notify-send "power controls" "Chromium multiple windows open"
        exit 1
    elif [ "$FIREFOX" -gt "1" ]; then
        notify-send "power controls" "Firefox multiple windows open"
        exit 1
    fi

    sleep 3

    # close all client windows
    # required for graceful exit since many apps aren't good SIGNAL citizens
    HYPRCMDS=$(hyprctl -j clients | jq -j '.[] | "dispatch closewindow address:\(.address); "')
    hyprctl --batch "$HYPRCMDS" >> /tmp/hypr/hyprexitwithgrace.log 2>&1

    notify-send "power controls" "Closing Applications..."

    sleep 2

    COUNT=$(hyprctl clients | grep -c "class:")
    if [ "$COUNT" -eq "0" ]; then
        notify-send "power controls" "Closed Applications."
        return
    else
        notify-send "power controls" "Some apps didn't close. Not shutting down."
        exit 1
    fi
}

function lock_screen() {
	loginctl lock-session
}

case "$1" in
        shutdown)
                close_apps
                systemctl poweroff
             ;;
        reboot | restart)
                close_apps
                systemctl reboot
            ;;

        suspend)
            lock_screen
            sleep 3
            systemctl suspend
            ;;

        hibernate)
            lock_screen
            systemctl hibernate
            ;;

        logout)
            close_apps
            hyprctl dispatch exit
            ;;

        lock)
            lock_screen
            ;;

        close)
            close_apps
            ;;
        *)
            echo $"Usage: $0 {shutdown|reboot|suspend|hibernate|logout|lock|close}"
            exit 1
esac
