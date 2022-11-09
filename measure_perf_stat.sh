# sudo apt install linux-tools-`uname -r`
# su -
# echo -1 >  /proc/sys/kernel/perf_event_paranoid
# perf stat -e uncore_imc/data_reads/,uncore_imc/data_reads/ -a
# perf stat -a \
# -e \
# uncore_imc_free_running_0/data_read/,uncore_imc_free_running_0/data_total/,uncore_imc_free_running_0/data_write/,\
# uncore_imc_free_running_1/data_read/,uncore_imc_free_running_1/data_total/,uncore_imc_free_running_1/data_write/


metrics=\
cycles,instructions,bus-cycles,cache-misses,L1-dcache-load-misses,\
L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-stores,\
LLC-store-misses,branch-loads,branch-load-misses

# metrics=\
# cycles,instructions,bus-cycles,cache-misses,L1-dcache-load-misses,\
# L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-stores,\
# LLC-store-misses,branch-loads,branch-load-misses,\
# uncore_imc/data_reads/,uncore_imc/data_reads/

filename=perf_stat_`date "+%Y%m%d-%H%M%S"`_

(
perf stat -a \
-e "$metrics" \
-r 0 -o "$filename"system_wide_time.txt -- sleep 1
) &
PID_PERF_SYSTEM_WIDE_TIMESERIES=$!

(
perf stat -a \
-e "$metrics" \
-o "$filename"system_wide.txt &
) &
PID_PERF_SYSTEM_WIDE=$!

(
top -b -d 1 > "$filename"top.txt
) &
PID_TOP_SYSTEM_WIDE=$!

(
vmstat -n 1 > "$filename"vmstat.txt
) &
PID_VMSTAT=$!

pid=`ps aux | grep component_cont | grep top | grep -oP '\d+' | head -1`
if [ $pid ]; then
    echo "Measure component_cont/top"
    (
    perf stat -p "$pid" \
    -e "$metrics" \
    -r 0 -o "$filename"lidar_top_time.txt -- sleep 1
    ) &
    PID_PERF_LIDAR_TOP_TIMESERIES=$!

    (
    perf stat -p "$pid" \
    -e "$metrics" \
    -o "$filename"lidar_top.txt &
    ) &
    PID_PERF_LIDAR_TOP_TIME_SERIES=$!

    (
    top -b -d 1 -p "$pid" > "$filename"top_lidar_top.txt
    ) &
    PID_TOP_LIDAR_TOP=$!
fi

last () {
    kill $PID_PERF_SYSTEM_WIDE_TIMESERIES $PID_PERF_SYSTEM_WIDE $PID_TOP_SYSTEM_WIDE $PID_VMSTAT
    if [ $pid ]; then
        kill $PID_PERF_LIDAR_TOP_TIMESERIES $PID_PERF_LIDAR_TOP_TIME_SERIES $PID_TOP_LIDAR_TOP
    fi
}
trap 'last' 1 2 3 15

sleep 1d
