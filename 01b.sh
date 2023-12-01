#!/bin/bash
set -eu
shopt -s extglob

declare -A english_digits=([one]=1 [two]=2 [three]=3 [four]=4 [five]=5
                           [six]=6 [seven]=7 [eight]=8 [nine]=9)
digits=({1..9})
digits_pattern=$(IFS='|' ; echo "${!english_digits[*]}|${digits[*]}")

sum=0
while read line ; do
    if [[ $line =~ ($digits_pattern) ]] ; then
        left=${BASH_REMATCH[1]}
    fi
    if [[ $line =~ .*($digits_pattern) ]] ; then
        right=${BASH_REMATCH[1]}
    fi
    if [[ ${english_digits[$left]:-} ]] ; then
        left=${english_digits[$left]}
    fi
    if [[ ${english_digits[$right]:-} ]] ; then
        right=${english_digits[$right]}
    fi
    add=$left$right
    (( sum += add ))
done
echo $sum
