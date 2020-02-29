#!/usr/bin/python
# -*- coding: UTF-8 -*-

base_file = open("time0.txt","r")
base_data = base_file.readlines()
base_file.close()

base_data_matrix=[]
for line in base_data:
    base_data_matrix.append(line.split())

for i in range(1,len(base_data_matrix)):
    for j in range(2, len(base_data_matrix[i])):
        base_data_matrix[i][j] = float(base_data_matrix[i][j])

data_matrix = []
for i in range(1,4):
    filename = "time" + str(i) + ".txt"
    data_temp_file = open(filename,"r")
    data_matrix_list = data_temp_file.readlines()
    data_temp_file.close()
    data_matrix_temp = []
    for line in data_matrix_list:
        data_matrix_temp.append(line.split())
    data_matrix.append(data_matrix_temp)

for k in range(0,len(data_matrix)):
    for i in range(1,len(data_matrix[k])):
        for j in range(2, len(data_matrix[k][i])):
            data_matrix[k][i][j] = float(data_matrix[k][i][j])


def diff_cal(a,b):
    return (a-b)/a*100


diff_matrix = []
diff_temp_1d = []
diff_temp_2d = []
for k in range(0,len(data_matrix)):
    for i in range(1,len(data_matrix[k])):
        for j in range(2, len(data_matrix[k][i])):
            diff_temp_1d.append(diff_cal(data_matrix[k][i][j],base_data_matrix[i][j]))
        diff_temp_2d.append(diff_temp_1d)
        diff_temp_1d = []
    diff_matrix.append(diff_temp_2d)
    diff_temp_2d = []

flag = 0
for k in range(0,len(data_matrix)):
    for i in range(0,len(data_matrix[k])-1):
        for j in range(0, len(data_matrix[k][i])-2):
            if (diff_matrix[k][i][j] >= 5) or (diff_matrix[k][i][j] <= -5):
                flag = 1
                break

if flag == 1:
    avr = [[0 for i in range(12)] for j in range(26)]

    for k in range(0, len(data_matrix)):
        for i in range(1, len(data_matrix[k])):
            for j in range(2, len(data_matrix[k][i])):
                data_matrix[k][i][j] = float(data_matrix[k][i][j])
                avr[i][j] = avr[i][j] + data_matrix[k][i][j] / 5

    output = open("time_avr.txt", "w")

    for i in range(0, len(data_matrix[0])):
        for j in range(0, len(data_matrix[0][i])):
            if i == 0:
                output.write(data_matrix[0][i][j] + "\t")
            elif j <= 1:
                output.write(data_matrix[0][i][j] + "\t")
            else:
                output.write(str(avr[i][j]) + "\t")
        output.write("\n")
    output.close()
    print("time_avr.txt is the final file")
else:
    print("time0.txt is the final file")

