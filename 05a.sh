#!/bin/bash
set -eu
set -o pipefail

read seeds
seeds=${seeds#*: }
declare -A map
for s in $seeds ; do
    map[$s]=$s
done

while read line ; do
    if [[ $line = "" ]] ; then
        continue
    fi

    if [[ $line = *: ]] ; then
        values=("${map[@]}")
        map=()
        for v in "${values[@]}" ; do
            map[$v]=$v
        done

    else
        dest_start=${line%% *}
        length=${line##* }
        src_start=${line#* }
        src_start=${src_start% *}

        for e in "${!map[@]}" ; do
            if (( e >= src_start && e <= src_start + length )) ; then
                map[$e]=$(( e - src_start + dest_start ))
            fi
        done
    fi
done

min=${map[@]}
min=${min%% *}
for e in "${map[@]}" ; do
    if (( e < min )) ; then
        min=$e
    fi
done
echo $min
