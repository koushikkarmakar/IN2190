#!/bin/bash
#@ wall_clock_limit = 00:30:00
#@ job_name = pos-gauss-mpi-intel
#@ job_type = MPICH
#@ output = out_gauss_64_intel_$(jobid).out
#@ error = out_gauss_64_intel_$(jobid).out
#@ class = test
#@ node = 4
#@ total_tasks = 64
#@ node_usage = not_shared
#@ energy_policy_tag = gauss
#@ minimize_time_to_solution = yes
#@ notification = never
#@ island_count = 1
#@ queue

. /etc/profile
. /etc/profile.d/modules.sh

module unload mpi.ibm
module load mpi.intel
module load python

#Uncomment the following lines for tracing
#module load scorep
#ulimit -c unlimited
#export SCOREP_TIMER="clock_gettime"
#export SCOREP_ENABLE_PROFILING=false
#export SCOREP_ENABLE_TRACING=true
#export SCOREP_TOTAL_MEMORY=2GB

date
module list

python bin_trans.py

echo "Tests starting..."
echo
if [ -f "time.txt" ];then
        rm time.txt
fi
for i in {0..4}
do

	(echo -e  "Size \t Num_process \t IO_avr \t Setup_avr \t Compute_avr \t MPI_avr \t Total_avr \t IO_sum \t Setup_sum \t Compute_sum \t MPI_sum \t Total_sum")>>time.txt
	(mpiexec -n 8 ./gauss ./ge_data/size64x64) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 16 ./gauss ./ge_data/size64x64) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 32 ./gauss ./ge_data/size64x64) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 64 ./gauss ./ge_data/size64x64) >& inter.txt
	python time_calculator.py
	date

	(mpiexec -n 8 ./gauss ./ge_data/size512x512) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 16 ./gauss ./ge_data/size512x512) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 32 ./gauss ./ge_data/size512x512) >& inter.txt
	python time_calculator.py
	(mpiexec -n 64 ./gauss ./ge_data/size512x512) >& inter.txt
	python time_calculator.py
	date

	(mpiexec -n 8 ./gauss ./ge_data/size1024x1024) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 16 ./gauss ./ge_data/size1024x1024) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 32 ./gauss ./ge_data/size1024x1024) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 64 ./gauss ./ge_data/size1024x1024) >& inter.txt
	python time_calculator.py
	date

	(mpiexec -n 8 ./gauss ./ge_data/size2048x2048) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 16 ./gauss ./ge_data/size2048x2048) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 32 ./gauss ./ge_data/size2048x2048) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 64 ./gauss ./ge_data/size2048x2048) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 8 ./gauss ./ge_data/size4096x4096) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 16 ./gauss ./ge_data/size4096x4096) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 32 ./gauss ./ge_data/size4096x4096) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 64 ./gauss ./ge_data/size4096x4096) >& inter.txt
	python time_calculator.py
	date

	(mpiexec -n 8 ./gauss ./ge_data/size8192x8192) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 16 ./gauss ./ge_data/size8192x8192) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 32 ./gauss ./ge_data/size8192x8192) >& inter.txt
	python time_calculator.py
	date
	(mpiexec -n 64 ./gauss ./ge_data/size8192x8192) >& inter.txt
	python time_calculator.py
	date

	filename="time"$i".txt"
    cp time.txt $filename
    rm time.txt
done

python time_diff_checker.py
python bin_to_txt_trans.py
echo
echo "Tests ended."


