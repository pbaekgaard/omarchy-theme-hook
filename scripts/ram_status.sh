#!/bin/bash
# RAM status with color coding

RAM_RAW=$(free | awk '$1 ~ /Mem/ {printf("%.0f", 100*$3/$2)}')

if [ "$RAM_RAW" -gt 80 ]; then
    COLOR="#[fg=red]"
elif [ "$RAM_RAW" -gt 50 ]; then
    COLOR="#[fg=yellow]"
else
    COLOR="#[fg=green]"
fi

echo "${COLOR}◧ RAM ${RAM_RAW}%#[default]"
