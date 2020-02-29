#!/bin/bash

function TaskTime_recorder()
{
        echo $1
        echo $2
        sed -i -e "s/Elapsed time/ $1 &/g" $2
        (sed -n '/Elapsed time/p' $2 |awk '{print $1 ":" $5 }')>>result_intel.txt
}		

cat number_intel.txt | while read line
do
        name_num=$line
        OLD_IFS="$IFS"
        IFS=":"
        num=($line)
        IFS="$OLD_IFS"
        file_name="pos_lulesh_hybrid_${num[1]}.out"
        while [ ! -f $file_name ]; 
        do
                wait_flag=1
        done
        wait_flag=0
        TaskTime_recorder $name_num $file_name
done
sort -t ":" -k 3n result_intel.txt -o result_intel.txt
(sed -n '1p' result_intel.txt|awk '{print $1 }') > interfile_intel.txt
sed -i -e "s/:/ /g" interfile_intel.txt
flags=$(sed -n '1p' interfile_intel.txt|awk '{print $1}')
rm Makefile
cp Makefile_original Makefile
sed -i -e "s/-g -O3 -I. -Wall/&$flags/g" Makefile
sed -i -e "s/LDFLAGS = -g -O3/&$flags/g" Makefile
sed -i -e "s/_/ /g" Makefile
vim Makefile