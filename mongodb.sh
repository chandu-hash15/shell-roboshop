#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USER_ID=$(id -u)
LOG_FOLDER="/var/log/shell_roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

mkdir -p "$LOG_FOLDER"

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


folder= "/etc/yum.repos.d/mongo.repo"

cp mongo.repo "$folder"
validate $? "copying mongo.repo file"

dnf list installed mongodb-org &>> $LOG_FILE
if [ $? -ne 0 ]; then
   dnf install mongodb-org -y &>> $LOG_FILE
   validate $? "mongodb"
else
    echo -e "mongodb is already installed $Y SKIPPING $N"
fi

systemctl enable mongod &>> $LOG_FILE
validate $? "enabling mongodb"
systemctl start mongod &>> $LOG_FILE
validate $? "starting mongodb"