#!/bin/sh -eu

# metrics=\
# cycles,instructions,bus-cycles,cache-misses,L1-dcache-load-misses,\
# L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-stores,\
# LLC-store-misses,branch-loads,branch-load-misses

metrics=\
cycles,instructions,bus-cycles,cache-misses,L1-dcache-load-misses,\
L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-stores,\
LLC-store-misses,branch-loads,branch-load-misses,\
uncore_imc/data_reads/,uncore_imc/data_reads/

DIR_NAME=perf_`date "+%Y%m%d-%H%M%S"`
echo save to "$DIR_NAME"

if [ ! -d "$DIR_NAME" ]; then
    mkdir "$DIR_NAME"
fi

cd "$DIR_NAME"

(
sudo perf record -F 99 -g -a \
--call-graph lbr -o perf_record_system_wide_lbr.data
) &
PID_PERF_RECORD_SYSTEM_WIDE_TIMESERIES=$!

(
sudo perf record -F 99 -g -a \
--call-graph dwarf -o perf_record_system_wide_dwarf.data
) &
PID_PERF_RECORD_SYSTEM_WIDE=$!

(
perf stat -a \
-e "$metrics" \
-r 0 -o perf_stat_system_wide_time.txt -- sleep 1
) &
PID_PERF_SYSTEM_WIDE_TIMESERIES=$!

(
perf stat -a \
-e "$metrics" \
-o perf_stat_system_wide.txt &
) &
PID_PERF_SYSTEM_WIDE=$!

(
top -b -d 1 > top.txt
) &
PID_TOP_SYSTEM_WIDE=$!

(
vmstat -n 1 > vmstat.txt
) &
PID_VMSTAT=$!

pid=`ps aux | grep component_cont | grep top | grep -oP '\d+' | head -1`
if [ $pid ]; then
    echo "Measure component_cont/top"

    (
    sudo perf record -F 99 -g -p "$pid" \
    --call-graph lbr -o perf_record_lidar_top_lbr.data
    ) &
    PID_PERF_RECORD_LIDAR_TOP_TIMESERIES=$!

    (
    sudo perf record -F 99 -g -p "$pid" \
    --call-graph dwarf -o perf_record_lidar_top_dwarf.data
    ) &
    PID_PERF_RECORD_LIDAR_TOP=$!

    (
    perf stat -p "$pid" \
    -e "$metrics" \
    -r 0 -o perf_stat_lidar_top_time.txt -- sleep 1
    ) &
    PID_PERF_LIDAR_TOP_TIMESERIES=$!

    (
    perf stat -p "$pid" \
    -e "$metrics" \
    -o perf_stat_lidar_top.txt &
    ) &
    PID_PERF_LIDAR_TOP_TIME_SERIES=$!

    (
    top -b -d 1 -p "$pid" > top_lidar_top.txt
    ) &
    PID_TOP_LIDAR_TOP=$!
fi

last () {
    sudo kill $PID_PERF_RECORD_SYSTEM_WIDE_TIMESERIES $PID_PERF_RECORD_SYSTEM_WIDE
    kill $PID_PERF_SYSTEM_WIDE_TIMESERIES $PID_PERF_SYSTEM_WIDE $PID_TOP_SYSTEM_WIDE $PID_VMSTAT
    if [ $pid ]; then
        sudo kill $PID_PERF_RECORD_LIDAR_TOP_TIMESERIES $PID_PERF_RECORD_LIDAR_TOP
        kill $PID_PERF_LIDAR_TOP_TIMESERIES $PID_PERF_LIDAR_TOP_TIME_SERIES $PID_TOP_LIDAR_TOP
    fi
}
trap 'last' 1 2 3 15

sleep 1d
