#!/bin/sh

xrdb merge ~/.Xresources
xbacklight -set 10 &
feh --bg-fill ~/Pictures/Wallpapers/man-and-dog-space.jpg &
picom &
xmodmap -e "clear Lock" -e "keycode 0x42 = Escape" &

# Start dunst for notifications
dunst &

# Start status bar script
dash ~/.config/chadwm/scripts/bar.sh &

# Start user applications
discord &
spotify &

# Start chadwm
while type chadwm >/dev/null; do chadwm && continue || break; done
