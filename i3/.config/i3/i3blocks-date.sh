#!/bin/bash

# Get day of week
day=$(date '+%A')

# Get day of month without leading zero
d=$(date '+%-d')

# Compute ordinal suffix
if [[ "$d" -eq 11 || "$d" -eq 12 || "$d" -eq 13 ]]; then
    suffix="th"
else
    case "$((d % 10))" in
        1) suffix="st" ;;
        2) suffix="nd" ;;
        3) suffix="rd" ;;
        *) suffix="th" ;;
    esac
fi

# Get month and year
month=$(date '+%B')
year=$(date '+%Y')

# Get time
time=$(date '+%H:%M:%S')

# Print full text
echo "$day ${d}${suffix} $month $year 🕐 $time"
