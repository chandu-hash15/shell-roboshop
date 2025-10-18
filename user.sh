#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell_roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$(pwd) 

mkdir -p "$LOG_FOLDER"

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ];then
    echo " you are not a root user "
    exit 1
else
    echo " you are root user "
fi

validate() {
    if [ $1 -ne 0 ];then
        echo -e "$2 ----- failed $R failed $N"
        exit 1
    else
        echo -e " $2 ----- $G success $N"
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
validate $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
validate $? "enabling nodejs"

dnf install nodejs -y &>>$LOG_FILE
validate $? "nodejs"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "roboshop user"
else
    echo -e " roboshop user already exists $Y SKIPPING $N"
fi

mkdir /app &>>$LOG_FILE
validate $? "app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
validate $? "downloading user code"

cd /app
validate $? "changing to app directory"

rm -rf /app/* &>>$LOG_FILE
validate $? "removing existing content"

unzip /tmp/user.zip &>>$LOG_FILE
validate $? "extracting user code"

npm install &>>$LOG_FILE
validate $? "installing nodejs dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
validate $? "copying user.service file"

systemctl daemon-reload
validate $? "daemon reload"

systemctl enable user &>>$LOG_FILE
validate $? "enabling user"

systemctl start user &>>$LOG_FILE
validate $? "starting user"