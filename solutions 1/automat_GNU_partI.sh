#!/bin/bash

cp Makefile Makefile_original
cp batch_serial.sh batch_serial_o.sh
if [ -f "result_GNU.txt" ];then
        rm result_GNU.txt
        touch result_GNU.txt
        echo "Update result_GNU.txt"
else
        touch result_GNU.txt
        echo "New result_GNU.txt"
fi
if [ -f "interfile_GNU.txt" ];then
        rm interfile_GNU.txt
        touch interfile_GNU.txt
        echo "Update interfile_GNU.txt"
else
        touch interfile_GNU.txt
        echo "New interfile_GNU.txt"
fi
if [ -f "number_GNU.txt" ];then
        rm number_GNU.txt
        touch number_GNU.txt
        echo "Update number_GNU.txt"
else
        touch number_GNU.txt
        echo "New number_GNU.txt"
fi

GNU_flag_array=(-march=native -fomit-frame-pointer -floop-block -floop-interchange -floop-strip-mine -funroll-loops -flto)
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
        (llsubmit $1) >& interfile_GNU.txt
        sed -i -e "s/\"/ /g" interfile_GNU.txt
        sed -i -e "s/\./ /g" interfile_GNU.txt
        sed -i -e "s/llsubmit: The job/ $2 &/g" interfile_GNU.txt
        (sed -n '/llsubmit: The job/p' interfile_GNU.txt|awk '{print $1 ":" $6 }')>>number_GNU.txt
}

for (( i = 0 ; i < ${#GNU_flag_array[@]} ; i++ ))
do
        rm Makefile
        cp Makefile_original Makefile
        flagnew="${GNU_flag_array[$i]}"
        flagname="${GNU_flag_array[$i]}"
        TaskNum_recorder ${flagnew} ${flagname}
        cp Makefile Makefile_inter1
        for (( j = $i + 1 ; j < ${#GNU_flag_array[@]} ; j++ ))
        do
                rm Makefile
                cp Makefile_inter1 Makefile
                flagnew_2="${flagnew}_${GNU_flag_array[$j]}"
                flagnew_20="${GNU_flag_array[$j]}"
                TaskNum_recorder ${flagnew_20} ${flagnew_2}
                cp Makefile Makefile_inter2
                for (( k = $j + 1 ; k < ${#GNU_flag_array[@]} ; k++ ))
                do
                        rm Makefile
                        cp Makefile_inter2 Makefile
                        flagnew_3="${flagnew_2}_${GNU_flag_array[$k]}"
                        flagnew_30="${GNU_flag_array[$k]}"
                        TaskNum_recorder ${flagnew_30} ${flagnew_3}
                        cp Makefile Makefile_inter3
                        for (( l = $k + 1 ; l < ${#GNU_flag_array[@]} ; l++ ))
                        do
                                rm Makefile
                                cp Makefile_inter3 Makefile
                                flagnew_4="${flagnew_3}_${GNU_flag_array[$l]}"
                                flagnew_40="${GNU_flag_array[$l]}"
                                TaskNum_recorder ${flagnew_40} ${flagnew_4}
                                cp Makefile Makefile_inter4
                                for (( m = $l + 1 ; m < ${#GNU_flag_array[@]} ; m++ ))
                                do
                                        rm Makefile
                                        cp Makefile_inter4 Makefile
                                        flagnew_5="${flagnew_4}_${GNU_flag_array[$m]}"
                                        flagnew_50="${GNU_flag_array[$m]}"
                                        TaskNum_recorder ${flagnew_50} ${flagnew_5}
                                        cp Makefile Makefile_inter5
                                        for (( n = $m + 1 ; n < ${#GNU_flag_array[@]} ; n++ ))
                                        do
                                                rm Makefile
                                                cp Makefile_inter5 Makefile
                                                flagnew_6="${flagnew_5}_${GNU_flag_array[$n]}"
                                                flagnew_60="${GNU_flag_array[$n]}"
                                                TaskNum_recorder ${flagnew_60} ${flagnew_6}
                                        done
                                done
                        done
                done
        done
done
