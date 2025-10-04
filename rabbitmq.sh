#!/bin/bash
N="\e[0m"
R="\e[0;31m"
G="\e[0;32m"
Y="\e[0;33m"
Dir_name=$PWD
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

cp $Dir_name/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$log_file
validate $? "copying rabbitmq"

dnf install rabbitmq-server -y &>>$log_file
validate $? "installing rabbitmq"

systemctl enable rabbitmq-server &>>$log_file
validate $? "enabling rabbitmq server"

systemctl start rabbitmq-server &>>$log_file
validate $? "started the rabbitmq"

USER_NAME="roboshop"
USER_PASS="roboshop123"
rabbitmqctl list_users | grep -w "$USER_NAME" &>>$log_file
if [ $? -ne 0 ]; then
    rabbitmqctl add_user $USER_NAME $USER_PASS &>>$log_file
    validate $? "settingup username and password"
else
    echo -e "username is already exists $Y SKIPPING $N" | tee -a $log_file
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$log_file
validate $? "setting permissions to rabbitmq to receive or send que to all traffic"

end_time=$(date +%s)
Total_time=$(($end_time-$start_time))
echo "Time taken for script $0 to execute is $Total_time seconds" | tee -a $log_file


