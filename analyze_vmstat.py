import argparse
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


def analyze_vmstat(dirname: str):
    print(f'--- analyze_vmstat: {dirname} ---')

    df = pd.DataFrame()

    with open(dirname + '/vmstat.txt') as f_csv:
        lines = f_csv.readlines()
        metrics = lines[1].split()
        for line in lines[3:]:      # ignore the first data
            values = line.split()
            values = [int(v) for v in values]
            df = pd.concat([df, pd.DataFrame([values], columns=metrics)], axis=0, ignore_index=True)

    df['us+sy'] = df['us'] + df['sy']

    plt.figure()
    plt.title('CPU usage [%]')
    plt.ylim(top=100)
    df['us+sy'].plot(legend=True)
    df['us'].plot(legend=True)
    df['sy'].plot(legend=True)
    plt.savefig(dirname + '/vmstat.jpg')
    plt.close()

    print('avg(us+sy) = ' , df['us+sy'].mean())
    print('avg(us) = ' , df['us'].mean())
    print('avg(sy) = ' , df['sy'].mean())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('dirname', nargs=1, type=str)
    args = parser.parse_args()
    analyze_vmstat(args.dirname[0])

if __name__ == '__main__':
    main()
