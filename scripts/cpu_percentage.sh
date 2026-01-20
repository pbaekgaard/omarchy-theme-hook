#!/bin/bash
# CPU percentage using /proc/stat (same method as Waybar)

# Read CPU stats twice with a small delay for averaging
read -r cpu user1 nice1 system1 idle1 iowait1 irq1 softirq1 steal1 guest1 guest_nice1 < <(grep '^cpu ' /proc/stat)
sleep 0.5
read -r cpu user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 guest2 guest_nice2 < <(grep '^cpu ' /proc/stat)

# Calculate deltas
user=$((user2 - user1))
nice=$((nice2 - nice1))
system=$((system2 - system1))
idle=$((idle2 - idle1))
iowait=$((iowait2 - iowait1))
irq=$((irq2 - irq1))
softirq=$((softirq2 - softirq1))

# Calculate total and usage
total=$((user + nice + system + idle + iowait + irq + softirq))
used=$((user + nice + system + irq + softirq))

# Calculate percentage
if [ $total -gt 0 ]; then
    usage=$(awk "BEGIN {printf \"%.0f\", ($used / $total) * 100}")
else
    usage=0
fi

echo "${usage}%"
