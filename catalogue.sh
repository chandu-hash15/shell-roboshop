#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOG_FOLDER="var/log/sheel_catalogue"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
mkdir -p "$LOG_FOLDER"
USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
    echo -e "you are not a roor user $R failed $N"
    exit 1
else
    echo -e "you are root user $G success $N"
fi

validat() [
    if [ $1 -ne 0 ]; then
        echo -e "$2 ------- $R failed $N"
        exit 1
    else
        echo -e "$2 ------- $G success $N"
    fi 
]

##### Nodejs installation #####
dnf module disable nodejs -y &>>$LOG_FILE
validate $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
validate $? "enabling nodejs"

dnf install nodejs -y &>>$LOG_FILE
validate $? "nodejs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
validate $? "adding roboshop user"

mkdir /app 
validate $? "creating app directory" 

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
validate $? "downloading catalogue component"

cd /app
validate $? "changing directory to /app"

unzip /tmp/catalogue.zip
validate $? "unzipping catalogue component"

npm install &>>$LOG_FILE
validate $? "installing nodejs dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service
validate $? "copying catalogue service file"


systemctl daemon-reload &>>$LOG_FILE
validate $? "reloading systemd"

systemctl enable catalogue &>>$LOG_FILE
validate $? "enabling catalogue service"

systemctl start catalogue &>>$LOG_FILE
validate $? "starting catalogue service"


cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copying mongo.repo file"   

dnf install mongodb-mongosh -y &>>$LOG_FILE
validate $? "mongodb-mongosh"

mongosh --host $MONGODB_HOST </app/db/master-data.js
validate $? "loading catalogue schema"

systemctl restart catalogue &>>$LOG_FILE
validate $? "restarting catalogue service"
