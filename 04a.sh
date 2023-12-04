#!/bin/bash
set -eu
set -o pipefail

main() {
    local points=0
    local line
    while read line ; do
        line=${line#Card }
        local id=${line%:*}
        local w=${line% | *}
        w=${w#*:}
        local -A winning=()
        for win in $w ; do
            winning[$win]=1
        done

        local m=${line#* | }
        local match
        local p=0
        for match in $m; do
            if [[ -v winning[$match] ]] ; then
                (( ++p ))
            fi
        done

        if (( p )) ; then
            (( points += 1 << (p - 1) ))
        fi
    done
    echo $points
}

main
