#!/bin/dash

interval=0

# load colors
. ~/.config/chadwm/scripts/bar_themes/catppuccin

cpu() {
  # Get total CPU time (user, nice, system, idle, iowait, irq, softirq)
  prev_total=0
  prev_idle=0

  cpu_times=$(grep '^cpu ' /proc/stat)
  idle_time=$(echo "$cpu_times" | awk '{print $5}')
  total_time=$(echo "$cpu_times" | awk '{print $2+$3+$4+$5+$6+$7+$8}')

  # Calculate CPU usage since last interval
  usage=$((100 * ((total_time - prev_total) - (idle_time - prev_idle)) / (total_time - prev_total)))

  # Update previous times
  prev_total=$total_time
  prev_idle=$idle_time

  printf "^c$red^  CPU: $usage%%" # Display CPU usage with percent
}

pkg_updates() {
  updates=$({ timeout 20 checkupdates 2>/dev/null || true; } | wc -l)

  if [ "$updates" -eq 0 ]; then
    printf "  ^c$green^    Fully Updated"
  else
    printf "  ^c$green^    $updates updates"
  fi
}

battery() {
  get_capacity="$(cat /sys/class/power_supply/BAT1/capacity)"
  printf "^c$blue^   $get_capacity%%" # Nerd Font icon for battery
}

brightness() {
  printf "^c$red^   " # Nerd Font icon for brightness
  printf "^c$red^%.0f\n" $(cat /sys/class/backlight/*/brightness)
}

mem() {
  printf "^c$blue^  " # Nerd Font icon for memory
  printf "^c$blue^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

# wlan() {
#   case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
#   up) printf "^c$black^ ^b$blue^ 󰤨 ^d^%s" " ^c$blue^Connected" ;;      # Nerd Font icon for Wi-Fi connected
#   down) printf "^c$black^ ^b$blue^ 󰤭 ^d^%s" " ^c$blue^Disconnected" ;; # Nerd Font icon for Wi-Fi disconnected
#   esac
# }

network() {
  ip=$(ip addr show $(ip route | grep '^default' | awk '{print $5}') | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
  printf "^c$blue^  IP: $ip" # Nerd Font icon for wired network
}

temperature() {
  cpu_temp=$(sensors | awk '/^Tctl/ {gsub(/\+/,""); printf "%d", $2}') # Remove '+' and output integer
  gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)

  printf "^c$red^  CPU: $cpu_temp°C "                         # Nerd Font icon for temperature
  [ -n "$gpu_temp" ] && printf "^c$green^  GPU: $gpu_temp°C " # Nerd Font icon for temperature
}

# keyboard_layout() {
#   layout=$(setxkbmap -query | grep layout | awk '{print $2}')
#   printf "^c$white^  $layout " # Nerd Font icon for keyboard
# }

clock() {
  printf "^c$blue^  "                         # Nerd Font icon for clock
  printf "^c$blue^ $(date '+%H:%M  %d/%m/%Y')" # Date and time format:  HH:MM DD/MM/YYYY
}

while true; do
  # Only check for updates every hour (3600 seconds)
  if [ $interval = 0 ] || [ $(($interval % 3600)) = 0 ]; then
    updates=$(pkg_updates)
  fi

  interval=$((interval + 1))

  sleep 1 && xsetroot -name "$updates   $(mem)   $(cpu)   $(network)   $(temperature)   $(clock)"
done
