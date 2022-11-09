```sh
git clone https://github.com/takeshi-iwanari/utilities.git --recursive

sh ./measure_perf_stat.sh
sh ./convert_flamegraph.sh  ./perf_yyyymmdd-hhmmss

# sudo apt install linux-tools-`uname -r`
# su -
# echo -1 >  /proc/sys/kernel/perf_event_paranoid
# perf stat -e uncore_imc/data_reads/,uncore_imc/data_reads/ -a
# perf stat -a \
# -e \
# uncore_imc_free_running_0/data_read/,uncore_imc_free_running_0/data_total/,uncore_imc_free_running_0/data_write/,\
# uncore_imc_free_running_1/data_read/,uncore_imc_free_running_1/data_total/,uncore_imc_free_running_1/data_write/

```
