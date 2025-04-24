#!/bin/sh
# Swap Caps Lock and Escape
setxkbmap -option caps:swapescape

xrdb merge ~/.Xresources
xbacklight -set 10 &
feh --bg-fill ~/Pictures/Wallpapers/1_rain_world.png &
picom &

# Start dunst for notifications
dunst &

# Start status bar script
dash ~/.config/chadwm/scripts/bar.sh &

# Start user applications
discord &
spotify &

# Start chadwm
while type chadwm >/dev/null; do chadwm && continue || break; done
