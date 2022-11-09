#!/bin/sh -eu


# git clone https://github.com/brendangregg/FlameGraph

cd $1

for filename in $(ls *.data); do
    sudo chown `whoami`:`whoami` "$filename"
    perf script -i "$filename" | ../FlameGraph/stackcollapse-perf.pl > out.perf-folded
    ../FlameGraph/flamegraph.pl out.perf-folded > "$filename".svg
done
