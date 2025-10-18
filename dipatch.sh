#!/bin/bash
R="/e[31m"
G="/e[32m"
Y="/e[33m"
N="/e[0m"
LOG_FOLDER="/var/Log/shell_roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ];then
    echo " you are not a root user "
    exit 1
else
    echo " you are root user "
fi  

mkdir -p "$LOG_FOLDER"


validate() {
    if [ $1 -ne 0 ];then
        echo -e "$2 ----- failed $R failed $N"
        exit 1
    else
        echo -e " $2 ----- $G success $N"
    fi
}
dnf install golang -y &>>$LOG_FILE
validate $? "golang"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "creating system user"
else

mkdir /app
curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &>>$LOG_FILE
validate $? "downloading dispatch application"

cd /app
rm -rf /app/*
validate $? "removing existing code"

unzip /tmp/dispatch.zip &>>$LOG_FILE
validate $? "extracting dispatch application"

cd /app 
go mod init dispatch
go get 
go build &>>$LOG_FILE
validate $? "building dispatch application"

cp dispatch.service /etc/systemd/system/dispatch.service &>>$LOG_FILE
validate $? "copying dispatch service file"

systemctl daemon-reload &>>$LOG_FILE
validate $? "daemon reload"
systemctl enable dispatch &>>$LOG_FILE
validate $? "enabling dispatch"
systemctl start dispatch &>>$LOG_FILE
validate $? "starting dispatch service"
    