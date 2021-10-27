#!/bin/bash

PREV_TOTAL=0
PREV_IDLE=0

cpu_temp() {
  temp=0
  for f in /sys/class/thermal/thermal_zone*
  do
    if [ "$(cat $f/type)" = "x86_pkg_temp" ]; then
      temp=$(cat $f/temp) 
      break
    fi
  done
  printf "$((temp / 1000))"
}

# https://www.mail-archive.com/linuxkernelnewbies@googlegroups.com/msg01690.html
cpu_usage() {
  CPU=(`cat /proc/stat | grep '^cpu '`) # Get the total CPU statistics.
  unset CPU[0]                          # Discard the "cpu" prefix.
  IDLE=${CPU[4]}                        # Get the idle CPU time.

  # Calculate the total CPU time.
  TOTAL=0
  for VALUE in "${CPU[@]}"; do
    let "TOTAL=$TOTAL+$VALUE"
  done

  # Calculate the CPU usage since we last checked.
  let "DIFF_IDLE=$IDLE-$PREV_IDLE"
  let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
  let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"

  # Remember the total and idle CPU times for the next check.
  PREV_TOTAL="$TOTAL"
  PREV_IDLE="$IDLE"
}

kbd() {
  printf "^c#33fcaf^   $(setxkbmap -query | awk '/layout/{ print $2 }')"
}

cpu() {
  printf "^c#56b6c2^  $DIFF_USAGE%% ($(cpu_temp)°C)"
}

mem() {
  printf "^c#ff6347^  $(free -h | awk 'NR==2{print $3}')"
}

vol() {
  vol="$(pactl list sinks | tr ' ' '\n' | grep -m1 '%' | tr -d '%')"
  if [ "$vol" -lt 30 ]; then
    icon=""
  elif [ "$vol" -lt 60 ]; then
    icon=""
  else
    icon=""
  fi
  printf "^c#b1a1c1^ 墳 $vol%%"
}

disk() {
  hdd="$(df -h | awk 'NR==2{print $4}')"
  printf "^c#a6d39f^  $hdd" 
}

clock() {
  printf "^c#a2c4cf^  $(date '+%d %B at %k:%M:%S') "
}

while true; do
  cpu_usage

  sleep 1 && xsetroot -name "$(kbd) $(cpu) $(mem) $(disk) $(vol) $(clock)"
done
