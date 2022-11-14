#!/bin/sh -eu

# metrics=\
# cycles,instructions,bus-cycles,cache-misses,L1-dcache-load-misses,\
# L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-stores,\
# LLC-store-misses,branch-loads,branch-load-misses

# metrics=\
# cycles,instructions,bus-cycles,cache-misses,L1-dcache-load-misses,\
# L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-stores,\
# LLC-store-misses,branch-loads,branch-load-misses,\
# uncore_imc_free_running_0/data_read/,uncore_imc_free_running_0/data_total/,uncore_imc_free_running_0/data_write/,\
# uncore_imc_free_running_1/data_read/,uncore_imc_free_running_1/data_total/,uncore_imc_free_running_1/data_write/

metrics=\
cycles,instructions,bus-cycles,cache-misses,L1-dcache-load-misses,\
L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-stores,\
LLC-store-misses,branch-loads,branch-load-misses,\
uncore_imc/data_reads/,uncore_imc/data_writes/

DIR_NAME=perf_`date "+%Y%m%d-%H%M%S"`
echo save to "$DIR_NAME"

if [ ! -d "$DIR_NAME" ]; then
    mkdir "$DIR_NAME"
fi

cd "$DIR_NAME"

sudo perf record -F 99 -g -a \
--call-graph lbr -o perf_record_system_wide_lbr.data -- sleep 10

sudo perf record -F 99 -g -a \
--call-graph dwarf -o perf_record_system_wide_dwarf.data -- sleep 10

# perf stat -a \
# -e "$metrics" \
# -r 0 -o perf_stat_system_wide_time.txt -- sleep 1

perf stat -a \
-e "$metrics" \
-o perf_stat_system_wide.txt -- sleep 10

top -b -d 1 -n 60 > top.txt

vmstat -n 1  60 > vmstat.txt

pid=`ps aux | grep component_cont | grep top | grep -oP '\d+' | head -1`
if [ $pid ]; then
    echo "Measure component_cont/top"

    sudo perf record -F 99 -g -p "$pid" \
    --call-graph lbr -o perf_record_lidar_top_lbr.data  -- sleep 10

    sudo perf record -F 99 -g -p "$pid" \
    --call-graph dwarf -o perf_record_lidar_top_dwarf.data  -- sleep 10

    # perf stat -p "$pid" \
    # -e "$metrics" \
    # -r 0 -o perf_stat_lidar_top_time.txt -- sleep 1

    perf stat -p "$pid" \
    -e "$metrics" \
    -o perf_stat_lidar_top.txt -- sleep 10

    top -b -d 1 -n 60 -p "$pid" > top_lidar_top.txt
fi

sudo chown `whoami`:`whoami` *
