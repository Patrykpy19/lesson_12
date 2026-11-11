#!/bin/bash

warning_level=85
while getopts "p:" opcja; do
    case $opcja in
        p) warning_level=$OPTARG;;
        *) echo  "Please do not use: $) [-p PROCENT]" >&2
        exit 2;;
    esac
done

df_output=$(df -h | tail -n +2| awk '{print $1}')
for position in $df_output; do
    size=$(df -h | grep "^$position" | head -n 1)
    percent=$(df -h | grep "^$position"| head -n 1 | awk '{print $5}')
    if [[ ${percent%\%} -gt $warning_level ]]; then
        echo "WARNING! This Filesystem's size is over $warning_level% !: $position $size $percent"
    fi
done
