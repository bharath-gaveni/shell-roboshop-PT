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

dnf module disable nodejs -y &>>$log_file
validate $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$log_file
validate $? "enabling nodejs"

dnf install nodejs -y &>>$log_file
validate $? "installing nodejs"

mkdir -p /app &>>$log_file
validate $? "creating app directory to place our application"

curl -o -L /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$log_file
validate $? "dowloading the zipped code to temp location"

cd /app &>>$log_file
validate $? "changing to app directory"

rm -rf /app/* &>>$log_file
validate $? "Removing the existing user code in app directory"

unzip /tmp/user.zip &>>$log_file
validate $? "unzipping the user code in app directory location"

cd /app &>>$log_file
validate $? "changing to app directory"

npm install &>>$log_file
validate $? "downloading the dependencies"

id roboshop &>>$log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    echo -e "roboshop user created $G Successfully $N" | tee -a $log_file
else
    echo -e "user already exists $Y SKIPPING $N" | tee -a $log_file
fi

cp $Dir_name/user.service /etc/systemd/system/user.service &>>$log_file
validate $? "copying user.service file and setting up systemd service"

systemctl daemon-reload &>>$log_file
validate $? "reloading the daemon to recongnize the new service created"

systemctl enable user &>>$log_file
validate $? "enabling user"

systemctl start user &>>$log_file
validate $? "started the user"

end_time=$(date +%s)
total_time=$(($end_time-$start_time))
echo "Total time taken to execute the script $0 is:$total_time seconds" | tee -a $log_file