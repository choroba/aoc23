#!/bin/bash
set -eu
shopt -s extglob

sum=0
while read line ; do
    line=${line##+([^0-9])}
    line=${line%%+([^0-9])}
    left=${line:0:1}
    right=${line: -1}
    add=$left$right
    (( sum += add ))
done
echo $sum
