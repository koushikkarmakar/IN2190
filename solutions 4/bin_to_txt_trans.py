# input sizeNxN_sol.bin
# output sizeNxN.sol

import numpy as np
size_list = ['size64x64', 'size512x512', 'size1024x1024', 'size2048x2048', 'size4096x4096', 'size8192x8192']
for i in range(6):
	file_input = './ge_data/' + size_list[i] + "_sol.bin"
    #file_input = './ge_data/' + size_list[i] + '_vec.bin'
    f = open(file_input, "r")
    x = np.fromfile(f, dtype=np.float)
    s = x.shape
    n = s[0]
    file_output = './ge_data/' +size_list[i] + '.sol'
    with open(file_output, 'w') as f:  # the file containing numbers
        f.write(str(n) + '\n')
        f.write((' '.join(['%1.6f']*x.size)) % tuple(x))
        f.write(' \n') # sizeNxN.sol has one more "\n" in the file.
    f.close()