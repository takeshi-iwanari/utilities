```sh
sudo apt install linux-tools-`uname -r`

git clone https://github.com/takeshi-iwanari/utilities.git --recursive

su -
echo -1 >  /proc/sys/kernel/perf_event_paranoid
exit

sh ./measure_perf_stat.sh
sh ./convert_flamegraph.sh  ./perf_yyyymmdd-hhmmss
```
