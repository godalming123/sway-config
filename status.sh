#!/bin/sh

# If there is a battery, then print it's info
test -d /sys/class/power_supply/BAT0/ && (
	# If there is less than 30% charge, add a red battery icon
	test $(cat /sys/class/power_supply/BAT0/capacity) -lt 30 && echo -n 🪫
	
	# Add an indicator for if the charge is increasing, decreasing, or staying the same
	bat_status=$(< /sys/class/power_supply/BAT0/status)
	test "$bat_status" "==" Full && echo -n ■
	test "$bat_status" "==" Charging && echo -n ▲
	test "$bat_status" "==" Discharging && echo -n ▼
	test "$bat_status" "==" "Not charging" && echo -n ○
	
	# Add the percentage charge
	echo -n "$(cat /sys/class/power_supply/BAT0/capacity)% ○ "
)

# Add the internal temprature
cat /sys/class/thermal/thermal_zone0/temp | awk '{printf ($1/1000) "°C ○ "}'

# Add the memory usage in GB and percent
free | grep Mem: | awk '{printf int($3/10000)/100 "GB " int($3/$2*100) "% ○ "}'

# Add the date
date +'%d/%m/%y ○ %I:%M'
