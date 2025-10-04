#!/bin/bash
N="\e[0m"
R="\e[0;31m"
G="\e[0;32m"
Y="\e[0;33m"
Host_name=mongodb.bharathgaveni.fun
id=$(id -u)

if [ $id -ne 0 ]; then
    echo -e "$R PLease execute the script $0 with root user access privilage $N"
    exit 1
fi

log_folder=/var/log/shell-roboshop-RT
script_name=$(echo $0 | cut -d "." -f1)
log_file=$log_folder/$script_name.log

mkdir -p $log_folder
start_time=$(date +%s)
echo "Script $0 execution started at time $(date)" | tee -a $log_file

validate() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 is $R Failed $N" | tee -a $log_file
        exit 1
    else
        echo -e "$2 is $G Success $N" | tee -a $log_file
    fi
}

dnf module disable nodejs -y &>>$log_file
validate $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$log_file
validate $? "enabling nodejs version 20"

dnf install nodejs -y &>>$log_file
validate $? "installing nodejs"

mkdir -p /app &>>$log_file
validate $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$log_file
validate $? "Downloading the catalogue code to temp location"

cd /app &>>$log_file
validate $? "changing to app directory location"

rm -rf /app/* &>>$log_file
validate $? "removing the existing catlaogue code"

unzip /tmp/catalogue.zip &>>$log_file
validate $? "unzipping the catalogue code in app dirctory location"

cd /app &>>$log_file
validate $? "changing to app directory"

npm install &>>$log_file
validate $? "Installing the dependencies"

id roboshop &>>$log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
    echo -e "user already exists $Y SKIPPING $N"
fi

cp $PWD/catalogue.service /etc/systemd/system/catalogue.service &>>$log_file
validate $? "copying the catalogue.service"

systemctl daemon-reload &>>$log_file
validate $? "Deamon reload"

systemctl enable catalogue &>>$log_file
validate $? "Enabling catalogue"

systemctl start catalogue &>>$log_file
validate $? "started catalogue"

cp $PWD/mongo.repo /etc/yum.repos.d/mongo.repo &>>$log_file
validate $? "copying mongo.repo"

dnf install mongodb-mongosh -y &>>$log_file
validate $? "installing mongodb client to load data"

index=$(mongosh $Host_name --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $index -le 0 ]; then
    mongosh --host $Host_name </app/db/master-data.js
else
    echo -e "Already loaded with data so $R SKIPPING $N"
fi

end_time=$(date +%s)
total_time=$(($end_time-$start_time))
echo "Total time taken to execte the script $0 is:$total_time seconds" | tee -a $log_file














