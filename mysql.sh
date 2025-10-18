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

dnf install mysql-server -y &>>$LOG_FILE
validate $? "mysql"

systemctl enable mysqld &>>$LOG_FILE
validate $? "enabling mysql"

systemctl start mysqld &>>$LOG_FILE
validate $? "starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
validate $? "setting mysql root password"   