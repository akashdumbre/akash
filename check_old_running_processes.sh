#!/bin/bash

#Array of comma seperated (,) processes to monitor, provide all to capture all processes.
process="java,bash"

#Retention period like process running since 2 days.
days=2

IFS=","
P_ARRAY=`for i in ${process[*]}; do echo -n "$i|" ; done ; echo "PID"`

if [ "$process" == "all" ]
then
	ps axo pid,ppid,pcpu,pmem,etimes,etime,user,cmd --sort=-pmem  | awk -v n=$days '$5 >= n*86400 {printf "%-5s | %-5s | %-5s | %-5s | %-8s | %-11s | %-6s | %-2s %-2s %-2s %-2s %-2s  \n",$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$(NF-1)}' > tmp_process_out_${BUILD_NUMBER}.log
else
	ps axo pid,ppid,pcpu,pmem,etimes,etime,user,cmd --sort=-pmem  | egrep "$P_ARRAY" | awk -v n=$days '$5 >= n*86400 {printf "%-5s | %-5s | %-5s | %-5s | %-8s | %-11s | %-6s | %-2s %-2s %-2s %-2s %-2s  \n",$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$(NF-1)}' > tmp_process_out_${BUILD_NUMBER}.log
fi


echo "======================================================================================"
if [ "`sed '1d' tmp_process_out_${BUILD_NUMBER}.log | wc -l`" -ge "1" ] 
then
	printf "\U2757 Following processes are running from $days days!\n"
    cat tmp_process_out_${BUILD_NUMBER}.log
    rm tmp_process_out_${BUILD_NUMBER}.log
    echo "======================================================================================"    
    exit 1
else 
	printf "\U2705 We are good! No Processes from array ($process) are running from 2 days\n"
    rm tmp_process_out_${BUILD_NUMBER}.log
    echo "======================================================================================"    
fi
