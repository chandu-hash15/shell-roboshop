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

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip
validate $? "downloading cart code"

cd /app
validate $? "changing to app directory"

rm -rf /app/* &>>$LOG_FILE
validate $? "removing existing content"

unzip /tmp/cart.zip &>>$LOG_FILE
validate $? "unzipping cart code"

npm install &>>$LOG_FILE
validate $? "installing nodejs dependencies"    

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service &>>$LOG_FILE
validate $? "copying cart service file" 

systemctl daemon-reload
validaate $? "daemon-reload"

systemctl enable cart &>>$LOG_FILE
validate $? "enabling cart"

systemctl start cart &>>$LOG_FILE
validate $? "starting cart"