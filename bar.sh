#!/bin/bash

PREV_TOTAL=0
PREV_IDLE=0
THERMAL_ZONE=""

BG_COLOR="^b#5EA1AC^"
BG_RESET="^b#2E3440^"
CL_COLOR="^c#D8DEE9^"
FG_COLOR="^c#ABB9CF^"

NORM_TEMP=45
CRIT_TEMP=75

IDLE_COLOR="^c#1E90FF^"
NORM_COLOR="^c#32CD32^"
CRIT_COLOR="^c#FF4500^"

thermal_zone() {
  for f in /sys/class/thermal/thermal_zone*
  do
    if [ "$(cat $f/type)" = "x86_pkg_temp" ]; then
      THERMAL_ZONE="$f"
      break
    fi
  done
}

thermal_zone

cpu_temp() {
  temp=0
  temp=$(cat $THERMAL_ZONE/temp) 
  temp="$((temp / 1000))"
  if [ "$temp" -gt "$CRIT_TEMP" ]; then
      printf "$CRIT_COLOR"
  elif [ "$temp" -gt "$NORM_TEMP" ]; then
      printf "$NORM_COLOR"
  else
      printf "$IDLE_COLOR"
  fi
  printf "$temp"
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
  printf "$BG_COLOR $CL_COLOR  $BG_RESET$FG_COLOR $(setxkbmap -query | awk '/layout/{ print $2 }')"
}

cpu() {
  printf "$BG_COLOR $CL_COLOR  $BG_RESET$FG_COLOR $DIFF_USAGE%% $(cpu_temp)°C"
}

mem() {
  printf "$BG_COLOR $CL_COLOR $BG_RESET$FG_COLOR $(free -h | awk 'NR==2{print $3}')"
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
  printf "$BG_COLOR $CL_COLOR墳 $BG_RESET$FG_COLOR $vol%%"
}

disk() {
  hdd="$(df -h | awk 'NR==2{print $4}')"
  printf "$BG_COLOR $CL_COLOR $BG_RESET$FG_COLOR $hdd" 
}

clock() {
  printf "$BG_COLOR $CL_COLOR $BG_RESET$FG_COLOR $(date '+%d %B at %k:%M:%S') "
}

while true; do
  cpu_usage

  sleep 1 && xsetroot -name "$(kbd) $(cpu) $(mem) $(disk) $(vol) $(clock)"
done
