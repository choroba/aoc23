#! /bin/bash
set -eu
set -o pipefail

map=()
read seeds
seeds=${seeds#*: }
while [[ $seeds == *' '* ]] ; do
    from=${seeds%% *}
    seeds=${seeds#* }
    range=${seeds%% *}
    seeds=${seeds#* }
    map+=("$from $(( from + range - 1)) 0")
done

while read line ; do
    if [[ ! $line ]] ; then
        continue
    fi

    if [[ $line = *: ]] ; then
        new_map=()
        for m in "${map[@]}" ; do
            set -- $m
            new_map+=("$(( $1 + $3 )) $(( $2 + $3 )) 0")
        done
        map=("${new_map[@]}")

    else
        set -- $line
        dest_start=$1
        src_start=$2
        length=$3
        rest=()
        for (( i = 0 ; i < ${#map[@]} ; ++i )) ; do
            e="${map[i]}"
            set -- $e
            from=$1
            to=$2
            shift=$3

            i0=$src_start
            (( i1 = src_start + length - 1 ))
            if (( i1 < from || i0 > to )) ; then
                continue
            fi

            if (( i0 < from )) ; then
                i0=$from
            elif (( i0 > from )) ; then
                rest+=("$from $(( i0 - 1 )) $shift")
            fi
            if (( i1 > to )) ; then
                i1=$to
            elif (( i1 < to )) ; then
                rest+=("$(( i1 + 1 )) $to $shift")
            fi
            map[i]="$i0 $i1 $(( dest_start - src_start ))"
        done
        map+=("${rest[@]}")
    fi
done
set -- ${map[0]}
(( min = $1 + $3 ))
for m in "${map[@]:1}" ; do
    set -- $m
    (( c = $1 + $3 ))
    if (( c < min )) ; then
        min=$c
    fi
done
echo $min
