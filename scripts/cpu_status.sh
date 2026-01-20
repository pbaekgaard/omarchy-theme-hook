#!/bin/bash
# CPU status with color coding

CPU_RAW=$(~/.config/tmux/scripts/cpu_percentage.sh | tr -d '%')

if [ "$CPU_RAW" -gt 80 ]; then
    COLOR="#[fg=red]"
elif [ "$CPU_RAW" -gt 50 ]; then
    COLOR="#[fg=yellow]"
else
    COLOR="#[fg=cyan]"
fi

echo "${COLOR}⚙  CPU ${CPU_RAW}%#[default]"
