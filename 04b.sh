#!/bin/bash
set -eu
set -o pipefail
shopt -s extglob

main() {
    local points=0
    local -A card
    local line
    while read line ; do
        line=${line#Card }
        local id=${line%:*}
        id=${id##+( )}
        (( card[$id] = ${card[$id]:-0} + 1 ))


        local w=${line% | *}
        w=${w#*:}
        local -A winning=()
        for win in $w ; do
            winning[$win]=1
        done

        local matches=${line#* | }
        local match
        local p=0
        for match in $matches; do
            if [[ -v winning[$match] ]] ; then
                (( ++p ))
            fi
        done
        local c
        for (( match = 1 ; match <= p ; ++match )) ; do
            (( c = id + match ))
            (( card[$c] = ${card[$c]:-0} + ${card[$id]} ))
        done
    done
    local sum=$(IFS='+'; echo "${card[*]}")
    echo $(( sum ))
}

main
