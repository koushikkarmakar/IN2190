#!/usr/bin/python
# -*- coding: UTF-8 -*-

text = open("inter.txt", "r")
text_list = text.readlines()
text.close()
IO = []
Setup = []
compute = []
MPI = []
Total = []
for line in text_list:
    if line[0] == '[':
        if line[1] == 'R':
            text_temp = line.replace(";"," ")
            text_temp = text_temp.split()
            IO.append(float(text_temp[3]))
            Setup.append(float(text_temp[5]))
            compute.append(float(text_temp[7]))
            MPI.append(float(text_temp[9]))
            Total.append(float(text_temp[11]))
    elif line[0] == 'W':
        text_temp = line.replace("/"," ")
        text_temp = text_temp.replace(".", " ")
        text_temp = text_temp.split()
        size = text_temp[7]


def sum(array):
    sum = 0
    for element in array:
        sum = sum + element
    return sum


def avr(array):
    return sum(array)/len(array)


IO_avr = avr(IO)
Setup_avr = avr(Setup)
compute_avr = avr(compute)
MPI_avr = avr(MPI)
Total_avr = avr(Total)
IO_sum = sum(IO)
Setup_sum = sum(Setup)
compute_sum = sum(compute)
MPI_sum = sum(MPI)
Total_sum = sum(Total)

text_output = size + "\t" + str(len(compute)) + "\t" + \
                str(IO_avr) + "\t" + str(Setup_avr) + "\t" + str(compute_avr) + "\t" + str(MPI_avr) + "\t" + str(Total_avr) + "\t" + \
                str(IO_sum) + "\t" + str(Setup_sum) + "\t" + str(compute_sum) + "\t" + str(MPI_sum) + "\t" + str(Total_sum) + "\n"

print text_output

output = open("time.txt","a")
output.write(text_output)
output.close()