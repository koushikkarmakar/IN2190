#!/usr/bin/python
# -*- coding: UTF-8 -*-

import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from scipy import log
import math


def linefit(x , y):
    N = float(len(x))
    sx,sy,sxx,syy,sxy=0,0,0,0,0
    for i in range(0,int(N)):
        sx  += x[i]
        sy  += y[i]
        sxx += x[i]*x[i]
        syy += y[i]*y[i]
        sxy += x[i]*y[i]
    a = (sy*sx/N -sxy)/( sx*sx/N -sxx)
    b = (sy - a*sx)/N
    r = abs(sy*sx/N-sxy)/math.sqrt((sxx-sx*sx/N)*(syy-sy*sy/N))
    return a,b,r


plot_file = open("time_avr_hw_non_blocking.txt","r")
plot_data = plot_file.readlines()
plot_file.close()

plot_data_matrix=[]
for line in plot_data:
    plot_data_matrix.append(line.split())

for i in range(1,len(plot_data_matrix)):
    for j in range(2, len(plot_data_matrix[i])):
        plot_data_matrix[i][j] = float(plot_data_matrix[i][j])

const_size = [[[0 for i in range(4)] for j in range(5)] for k in range(6)]

for k in range(6):
    for i in range(4):
        for j in range(5):
            const_size[k][j][i] = plot_data_matrix[4 * k + i + 1][j + 2]

const_pro = [[[0 for i in range(6)] for j in range(5)] for k in range(4)]

for k in range(4):
    for i in range(6):
        for j in range(5):
            const_pro[k][j][i] = plot_data_matrix[4 * i + k + 1][j + 7]

x_size = [8, 16, 32, 64]
cases_size = ['size64x64', 'size512x512', 'size1024x1024', 'size2048x2048', 'size4096x4096', 'size8192x8192']
label_set_size = ["IO_avr", "Setup_avr", "Compute_avr", "MPI_avr", "Total_avr"]
x_pro = [64, 512, 1024, 2048, 4096, 8192]
cases_pro = ['8', '16', '32', '64']
label_set_pro = ["IO_sum", "Setup_sum", "Compute_sum", "MPI_sum", "Total_sum"]

ax_size = []
ax_pro = []
figsize = (20, 15)
cols = 2
colors = ['#1f77b4',
          '#ff7f0e',
          '#2ca02c',
          '#d62728',
          '#9467bd',
          '#8c564b',
          '#e377c2',
          '#7f7f7f',
          '#bcbd22',
          '#17becf',
          '#1a55FF']
gs = gridspec.GridSpec(len(cases_size) // cols + 1, cols)
gs.update(hspace=0.4)


fig1 = plt.figure(num=1, figsize=figsize)
for i, case in enumerate(cases_size):
    row = (i // cols)
    col = i % cols
    ax_size.append(fig1.add_subplot(gs[row, col]))
    ax_size[-1].set_title(case)
    for j in range(len(label_set_size)):
        ax_size[-1].plot(x_size, const_size[i][j], marker='o', label=str(label_set_size[j]))
        ax_size[-1].set_xlabel('Processes')
        ax_size[-1].set_ylabel('Time')
ax_size[-1].legend(bbox_to_anchor=(1, 1), loc=2, borderaxespad=0.)
fig1.tight_layout()

fig2 = plt.figure(num=2, figsize=figsize)
for i, case in enumerate(cases_pro):
    row = (i // cols)
    col = i % cols
    ax_pro.append(fig2.add_subplot(gs[row, col]))
    ax_pro[-1].set_title(case)
    for j in range(len(label_set_pro)):
        ax_pro[-1].plot(x_pro, const_pro[i][j], marker='o', label=str(label_set_pro[j]))
        ax_pro[-1].set_xscale('log')
        ax_pro[-1].set_yscale('log')
        ax_pro[-1].set_xlabel('Size')
        ax_pro[-1].set_ylabel('Time')
ax_pro[-1].legend(bbox_to_anchor=(1, 1), loc=2, borderaxespad=0.)
fig2.tight_layout()

x_pro_fit = [0 for i in range(6)]
const_pro_fit = [0 for i in range(6)]
print("MPI time")
for k in range(4):
    for i in range(6):
        x_pro_fit[i] = log(x_pro[i])
        const_pro_fit[i] = log(const_pro[k][3][i])
    a, b, r = linefit(x_pro_fit, const_pro_fit)
    print("%d Linear regression: y = %10.5f x + %10.5f , r=%10.5f" % (k, a, b, r) )
print("Compute time")
for k in range(4):
    for i in range(6):
        x_pro_fit[i] = log(x_pro[i])
        const_pro_fit[i] = log(const_pro[k][2][i])
    a, b, r = linefit(x_pro_fit, const_pro_fit)
    print("%d Linear regression: y = %10.5f x + %10.5f , r=%10.5f" % (k, a, b, r) )
plt.show()
