#!/bin/bash
N="\e[0m"
R="\e[0;31m"
G="\e[0;32m"
Y="\e[0;33m"

id=$(id -u)

if [ $id -ne 0 ]; then
    echo -e "$R Please execute $0 with root user access privilage $N"
    exit 1
fi

log_folder=/var/log/shell-roboshop-PT
script_name=$(echo $0 | cut -d "." -f1)
log_file=$log_folder/$script_name.log

mkdir -p $log_folder
start_time=$(date +%s)
echo "script $0 started at time: $(date)" | tee -a $log_file

cp $PWD/mongo.repo  /etc/yum.repos.d/mongo.repo
validate() {
    if [ $1 -ne 0 ]; then
        echo -e "$2  is $R Failed $N" | tee -a $log_file
        exit 1
    else
        echo -e "$2 is $G Success $N" | tee -a $log_file
    fi
}

dnf install mongodb-org -y &>>$log_file
validate $? "installing mongodb"

systemctl enable mongod  &>>$log_file
validate $? "enabling mongodb"

systemctl start mongod &>>$log_file
validate $? "started mongodb"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>$log_file
validate $? "Allowing remote connections to mongodb"

systemctl restart mongod &>>$log_file
validate $? "Restarting the mongodb"

end_time=$(date +%s)
total_time=$(($end_time-$start_time))
echo "Time taken to execute script $0 is:$total_time seconds"











