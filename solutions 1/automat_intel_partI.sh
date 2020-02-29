#!/bin/bash

cp Makefile Makefile_original
cp batch_serial.sh batch_serial_o.sh
if [ -f "result_intel.txt" ];then
        rm result_intel.txt
        touch result_intel.txt
        echo "Update result_intel.txt"
else
        touch result_intel.txt
        echo "New result_intel.txt"
fi
if [ -f "interfile_intel.txt" ];then
        rm interfile_intel.txt
        touch interfile_intel.txt
        echo "Update interfile_intel.txt"
else
        touch interfile_intel.txt
        echo "New interfile_intel.txt"
fi
if [ -f "number_intel.txt" ];then
        rm number_intel.txt
        touch number_intel.txt
        echo "Update number_intel.txt"
else
        touch number_intel.txt
        echo "New number_intel.txt"
fi

Intel_flag_array=(-march=native -xHost -unroll -ipo)
flagnew=""

function TaskNum_recorder()
{
        echo $1
        echo $2
        sed -i -e "s/-g -O3 -I. -Wall/& $1/g" Makefile
        sed -i -e "s/LDFLAGS = -g -O3/& $1/g" Makefile
        make clean
        make
        cp batch_serial_o.sh batch_serial.sh
        sed -i -e "s/lulesh2/&$2/g" batch_serial.sh
        file_name="lulesh2$2.0"
        batch_name="batch_serial$2.sh"
        cp lulesh2.0 $file_name
        cp batch_serial.sh $batch_name
        rm batch_serial.sh
        Task_submiter $batch_name $2
}

function Task_submiter()
{
        echo $1
        echo $2
        (llsubmit $1) >& interfile_intel.txt
        sed -i -e "s/\"/ /g" interfile_intel.txt
        sed -i -e "s/\./ /g" interfile_intel.txt
        sed -i -e "s/llsubmit: The job/ $2 &/g" interfile_intel.txt
        (sed -n '/llsubmit: The job/p' interfile_intel.txt|awk '{print $1 ":" $6 }')>>number_intel.txt
}

for (( i = 0 ; i < ${#Intel_flag_array[@]} ; i++ ))
do
        rm Makefile
        cp Makefile_original Makefile
        flagnew="${Intel_flag_array[$i]}"
        flagname="${Intel_flag_array[$i]}"
        TaskNum_recorder ${flagnew} ${flagname}
        cp Makefile Makefile_inter1
        for (( j = $i + 1 ; j < ${#Intel_flag_array[@]} ; j++ ))
        do
                rm Makefile
                cp Makefile_inter1 Makefile
                flagnew_2="${flagnew}_${Intel_flag_array[$j]}"
                flagnew_20="${Intel_flag_array[$j]}"
                TaskNum_recorder ${flagnew_20} ${flagnew_2}
                cp Makefile Makefile_inter2
                for (( k = $j + 1 ; k < ${#Intel_flag_array[@]} ; k++ ))
                do
                        rm Makefile
                        cp Makefile_inter2 Makefile
                        flagnew_3="${flagnew_2}_${Intel_flag_array[$k]}"
                                                flagnew_30="${Intel_flag_array[$k]}"
                        TaskNum_recorder ${flagnew_30} ${flagnew_3}
                        cp Makefile Makefile_inter3
                        for (( l = $k + 1 ; l < ${#Intel_flag_array[@]} ; l++ ))
                        do
                                rm Makefile
                                cp Makefile_inter3 Makefile
                                flagnew_4="${flagnew_3}_${Intel_flag_array[$l]}"
                                flagnew_40="${Intel_flag_array[$l]}"
                                TaskNum_recorder ${flagnew_40} ${flagnew_4}
                        done
                done
        done
done
