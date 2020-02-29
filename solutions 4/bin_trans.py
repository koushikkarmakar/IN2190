# input sizeNxN.vec
# output sizeNxN_vec.bin
# input sizeNxN.mat
# output sizeNxN.bin

import numpy as np
size_list = ["size64x64", 'size512x512', 'size1024x1024', 'size2048x2048', 'size4096x4096', 'size8192x8192']
for i in range(6):
	file_input = "./ge_data/" + size_list[i] + ".vec"
	x = np.loadtxt(file_input, dtype=np.float, skiprows=(1), unpack=False)
	s = x.shape
	n = s[0]
	size = n
	x = x.flatten()
	x = np.insert(x, 0, size)
	file_output = './ge_data/' +size_list[i] + '_vec.bin'
	x.tofile(file_output)

for i in range(6):
	file_input = './ge_data/' + size_list[i] + '.mat'
    x = np.loadtxt(file_input, dtype=np.float, skiprows=(1), unpack=False)
    file_output = './ge_data/' + size_list[i] + '.bin'
    s = x.shape
    n = s[0]
    size = np.array([n, n])
    x = x.flatten()
    x = np.insert(x, 0, size)
    x[0] = int(n)
    x.tofile(file_output)