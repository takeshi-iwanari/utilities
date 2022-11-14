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

def analyze_top(dirname: str, process_name: str):
    print(f'--- analyze_top: {dirname} ---')

    df = pd.DataFrame()
    metrics = ['us', 'sy', 'us+sy', f'cpu_{process_name}', 'mem_system', f'mem(RES)_{process_name}']

    with open(dirname + '/top.txt') as f_csv:
        lines = f_csv.readlines()
        system_values = [line.split() for line in lines if '%Cpu(s)' in line]
        system_mem_values = [line.split() for line in lines if 'MiB Mem' in line]
        process_values = [line.split() for line in lines if process_name in line]

        data_num = min(len(system_values), len(system_mem_values), len(process_values))

        for i in range(data_num):
            us = float(system_values[i][1])
            sy = float(system_values[i][3])
            us_sy = us+sy
            cpu_process = float(process_values[i][8])
            mem_system = float(system_mem_values[i][7]) * 1024 * 1024
            mem_process = conv_str_to_float(process_values[i][5]) * 1024
            mem_system /= 1024*1024
            mem_process /= 1024*1024
            df = pd.concat([df, pd.DataFrame([[us, sy, us_sy, cpu_process, mem_system, mem_process]], columns=metrics)], axis=0, ignore_index=True)

    plt.figure()
    plt.title('CPU usage [%]')
    plt.ylim(top=100)
    df['us+sy'].plot(legend=True)
    df['us'].plot(legend=True)
    df['sy'].plot(legend=True)
    df[f'cpu_{process_name}'].plot(legend=True)
    plt.savefig(dirname + '/top_cpu.jpg')
    plt.close()

    plt.figure()
    plt.title('Memory usage [MiB]')
    df['mem_system'].plot(legend=True)
    df[f'mem(RES)_{process_name}'].plot(legend=True)
    plt.savefig(dirname + '/top_mem.jpg')
    plt.close()

    print('avg(us+sy/100%) = ' , df['us+sy'].mean())
    print('avg(us/100%) = ' , df['us'].mean())
    print('avg(sy/100%) = ' , df['sy'].mean())
    print(f'avg({process_name}/100xCore%) = ' , df[f'cpu_{process_name}'].mean())

    print('avg(mem_system) MiB = ' , df['mem_system'].mean())
    print(f'avg(mem(RES)_{process_name}) MiB = ' , df[f'mem(RES)_{process_name}'].mean())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('dirname', nargs=1, type=str)
    parser.add_argument('process_name', nargs='?', type=str, default='component_conta')
    args = parser.parse_args()
    analyze_top(args.dirname[0], args.process_name)

if __name__ == '__main__':
    main()
