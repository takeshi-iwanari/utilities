# git clone https://github.com/brendangregg/FlameGraph

cd FlameGraph

filename=perf_record_`date "+%Y%m%d-%H%M%S"`_

sudo perf record -F 99 -g -a \
--call-graph lbr -o "$filename"system_wide_lbr.data -- sleep 5 &

sudo perf record -F 99 -g -a \
--call-graph dwarf -o "$filename"system_wide_dwarf.data -- sleep 5 &

pid=`ps aux | grep component_cont | grep top | grep -oP '\d+' | head -1`
if [ $pid ]; then
    sudo perf record -F 99 -g -p $pid \
    --call-graph lbr -o "$filename"lidar_top_lbr.data -- sleep 5 &

    sudo perf record -F 99 -g -p $pid \
    --call-graph dwarf -o "$filename"lidar_top_dwarf.data -- sleep 5 &
fi

sleep 8

sudo chown `whoami`:`whoami` perf_record_*

perf script -i "$filename"system_wide_lbr.data | ./stackcollapse-perf.pl > out.perf-folded
./flamegraph.pl out.perf-folded > "$filename"system_wide_lbr.svg

perf script -i "$filename"system_wide_dwarf.data | ./stackcollapse-perf.pl > out.perf-folded
./flamegraph.pl out.perf-folded > "$filename"system_wide_dwarf.svg

if [ $pid ]; then
    perf script -i "$filename"lidar_top_lbr.data | ./stackcollapse-perf.pl > out.perf-folded
    ./flamegraph.pl out.perf-folded > "$filename"lidar_top_lbr.svg

    perf script -i "$filename"lidar_top_dwarf.data | ./stackcollapse-perf.pl > out.perf-folded
    ./flamegraph.pl out.perf-folded > "$filename"lidar_top_dwarf.svg
fi
