import argparse
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


def conv_str_to_float(val: str) -> float:
    if 'k' in val or 'K' in val:
        return float(val[:-1])
    elif 'm' in val or 'M' in val:
        return float(val[:-1])
    elif 'g' in val or 'G' in val:
        return float(val[:-1])
    else:
        return float(val)

def analyze_top(dirname: str):
    print(f'--- analyze_top: {dirname} ---')

    df_cpu = pd.DataFrame()
    df_mem = pd.DataFrame()
    metrics_cpu = ['us', 'sy', 'us+sy']
    metrics_mem = ['mem_system']

    with open(dirname + '/top.txt') as f_csv:
        lines = f_csv.readlines()
        lines = [line.split() for line in lines if len(line.split()) > 0]
        pid_list = [(line[0], line[11]) for line in lines if str.isdigit(line[0])]
        pid_list = list(dict.fromkeys(pid_list))

        system_values = [line for line in lines if '%Cpu(s)' in line[0]]
        data_num = len(system_values)
        system_mem_values = [line for line in lines if 'MiB' in line[0] and 'Mem' in line[1]]
        process_values_list = []
        for pid in pid_list:
            process_values = [line for line in lines if pid[0] == line[0]]
            if data_num != len(process_values):
                pid_list.remove(pid)
                continue
            process_values_list += [process_values]
            metrics_cpu += [pid]
            metrics_mem += [pid]

        for i in range(data_num):
            us = float(system_values[i][1])
            sy = float(system_values[i][3])
            us_sy = us+sy
            mem_system = float(system_mem_values[i][7]) * 1024 * 1024
            mem_system /= 1024*1024
            value_cpu = [us, sy, us_sy]
            value_mem = [mem_system]
            for process_values in process_values_list:
                cpu_process = float(process_values[i][8])
                mem_process = conv_str_to_float(process_values[i][5]) * 1024
                mem_process /= 1024*1024
                value_cpu += [cpu_process]
                value_mem += [mem_process]
            df_cpu = pd.concat([df_cpu, pd.DataFrame([value_cpu], columns=metrics_cpu)], axis=0, ignore_index=True)
            df_mem = pd.concat([df_mem, pd.DataFrame([value_mem], columns=metrics_mem)], axis=0, ignore_index=True)

    # plt.figure()
    # plt.title('CPU usage [%]')
    # plt.ylim(top=100)
    # df_cpu['us+sy'].plot(legend=True)
    # df_cpu['us'].plot(legend=True)
    # df_cpu['sy'].plot(legend=True)
    # for pid in pid_list:
    #     if pid in metrics_cpu:
    #         df_cpu[pid].plot(legend=True)
    # plt.savefig(dirname + '/top_cpu.jpg')
    # plt.close()

    # plt.figure()
    # plt.title('Memory usage [MiB]')
    # df_mem['mem_system'].plot(legend=True)
    # for pid in pid_list:
    #     if pid in metrics_cpu:
    #         df_mem[pid].plot(legend=True)
    # plt.savefig(dirname + '/top_mem.jpg')
    # plt.close()

    print('us+sy/100% = ' , df_cpu['us+sy'].mean())
    print('us/100% = ' , df_cpu['us'].mean())
    print('sy/100% = ' , df_cpu['sy'].mean())

    pid_list_top = sorted(pid_list,
        key=lambda x: df_cpu[x].mean() if x in metrics_cpu else -1,
        reverse=True
    )

    for pid in pid_list_top:
        if pid in metrics_cpu:
            print(f'{pid[0]}({pid[1]}) = {df_cpu[pid].mean():.1f}')

    # print('mem_system MiB = ' , df_mem['mem_system'].mean())
    # for pid in pid_list_top:
    #     if pid in metrics_cpu:
    #         print(f'{pid[0]}({pid[1]})  MiB = ' , df_mem[pid].mean())

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('dirname', nargs=1, type=str)
    args = parser.parse_args()
    analyze_top(args.dirname[0])

if __name__ == '__main__':
    main()
