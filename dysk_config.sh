#!/bin/bash

config_file="$HOME/.config/dysk.conf"

# 1. default
warning_level=85
where="default"

# 2. config file
if [[ -f $config_file ]]; then
    while IFS='=' read -r key value; do
        if [[ $key == "warning_level" ]]; then
            warning_level=$value
            where="file"
        elif [[ -n $key && $key != \#* ]]; then
            echo "Warning: unknown key in file: $key" >&2
        fi
    done < "$config_file"
fi

# 3. environment
if [[ -n $DYSK_WARNING_LEVEL ]]; then
    warning_level=$DYSK_WARNING_LEVEL
    where="environment"
fi

# 4. command line
show=0
while getopts "p:-:" opcja; do
    if [[ $opcja == "p" ]]; then
        warning_level=$OPTARG
        where="command line"
    elif [[ $OPTARG == "pokaz-konfiguracje" ]]; then
        show=1
    fi
done

if [[ $show -eq 1 ]]; then
    echo "warning_level = $warning_level (source: $where)"
    exit 0
fi

df_output=$(df -h | tail -n +2| awk '{print $1}')
for position in $df_output; do
    size=$(df -h | grep "^$position" | head -n 1)
    percent=$(df -h | grep "^$position"| head -n 1 | awk '{print $5}')
    if [[ ${percent%\%} -gt $warning_level ]]; then
        echo "WARNING! This Filesystem's size is over $warning_level% !: $position $size $percent"
    fi
done
