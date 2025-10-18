#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="var/log/shell_roboshop"
SCRIPT_NAME=$(echo$0 | cut -d " ."  -f1)
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

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
validate $? "copying rabbitmq repo file"

dnf install rabbitmq-server -y &>>$LOG_FILE
validate $? "rabbitmq installation"

systemctl enable rabbitmq-server &>>$LOG_FILE
validate $? "enabling rabbitmq"

systemctl start rabbitmq-server &>>$LOG_FILE
validate $? "starting rabbitmq"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
    validate $? "adding roboshop user to rabbitmq"
else
    echo -e " user already exist ... $Y SKIPPING $N"
fi
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
validate $? "setting permissions to roboshop user"