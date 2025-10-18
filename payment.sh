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

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
validate $? "installing python3"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "creating system user"
else
    echo -e " user already exist ... $Y SKIPPING $N"
fi
mkdir -p /app

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
cd /app
rm -rf /app/* 
unzip /tmp/payment.zip

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
cd /app 
unzip /tmp/payment.zip &>>$LOG_FILE

cd /app

pip3 install -r requirements.txt &>>$LOG_FILE
validate $? "installing python dependencies"
cp payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
validate $? "copying payment service file"

systemctl daemon-reload &>>$LOG_FILE
validate $? "daemon reload"

systemctl enable payment &>>$LOG_FILE
validate $? "enabling payment service"  

systemctl start payment &>>$LOG_FILE
validate $? "starting payment service"