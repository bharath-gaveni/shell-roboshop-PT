#!/bin/bash

N="\e[0m"
R="\e[0;31m"
G="\e[0;32m"
Y="\e[0;33m"

id=$(id -u)

if [ $id -ne 0 ]; then
    echo -e "$R Please execute the script $0 with root user access privilage $N"
    exit 1
fi

log_folder=/var/log/shell-roboshop-PT
script_name=$(echo $0 | cut -d "." -f1)
log_file=$log_folder/$script_name.log

mkdir -p $log_folder
start_time=$(date +%s)
echo "Script $0 execution started time at:$(date)" | tee -a $log_file

validate() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 is $R Failed $N" | tee -a $log_file
        exit 1
    else
        echo -e "$2 is $G Success $N" | tee -a $log_file
    fi
}

dnf install mysql-server -y &>>$log_file
validate $? "installing mysql server"

systemctl enable mysqld &>>$log_file
validate $? "enabling mysql"

systemctl start mysqld &>>$log_file
validate $? "start mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$log_file
validate $? "setting up password for mysql to connect to db as root is default user"

end_time=$(date +%s)
Total_time=$(($end_time-$start_time))
    echo "Time taken for script $0 to execute is $Total_time seconds" | tee -a $log_file