#!/bin/bash

# This script continuously monitors the power status.
# It disables CPU cores 4 and above when on battery,
# and re-enables them when charging.

while true; do
  if [ "$(cat /sys/class/power_supply/AC/online)" -eq 0 ]; then
    # On battery: Turn cores offline
    for ((i = 5; i < $(ls /sys/devices/system/cpu/cpu[0-9]* | wc -l); i++)); do
      if [ -f "/sys/devices/system/cpu/cpu$i/online" ]; then
        echo 0 >/sys/devices/system/cpu/cpu$i/online
      fi
    done
  else
    # On AC power: Turn cores online
    for ((i = 5; i < $(ls /sys/devices/system/cpu/cpu[0-9]* | wc -l); i++)); do
      if [ -f "/sys/devices/system/cpu/cpu$i/online" ]; then
        echo 1 >/sys/devices/system/cpu/cpu$i/online
      fi
    done
  fi
  sleep 15
done
