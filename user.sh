#!/bin/bash
N="\e[0m"
R="\e[0;31m"
G="\e[0;32m"
Y="\e[0;33m"
Dir_name=$PWD

id=$(id -u)

if [ $id -ne 0 ]; then
    echo -e "$R please execute the script $0 with root user privilage access $N"
    exit 1
fi

log_folder=/var/log/shell-roboshop-PT
script_name=$(echo $0 | cut -d "." -f1)
log_file=$log_folder/$script_name.log
start_time=$(date +%s)
mkdir -p $log_folder
echo "Script $0 execution started at time:$(date)" | tee -a $log_file

validate() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 is $R Failed $N" | tee -a $log_file
        exit 1
    else
        echo -e "$2 is $G success $N" | tee -a $log_file
    fi
}












end_time=$(date +%s)
total_time=$(($end_time-$start_time))
echo "Total time taken to execute the script $0 is:$total_time seconds" | tee -a $log_file