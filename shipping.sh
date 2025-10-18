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


dnf install maven -y &>>$LOG_FILE
validate $? "maven"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "creating system user"
else
    echo -e " user already exist ... $Y SKIPPING $N"
fi  
mkdir -p /app

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
validate $? "downloading shipping application"

cd /app

rm -rf /app/*
validate $? "removing existing code"

unzip /tmp/shipping.zip &>>$LOG_FILE
validate $? "extracting shipping application"

cd /app
mvn clean package &>>$LOG_FILE
validate $? "building shipping application"

mv target/shipping-1.0.jar shipping.jar

cp shipping.service /etc/systemd/system/shipping.service
validate $? "copying shipping.service file"

systemctl daemon-reload &>>$LOG_FILE
validate $? "daemon reloading"


systemctl enable shipping &>>$LOG_FILE
validate $? "enabling shipping"

systemctl start shipping &>>$LOG_FILE
validate $? "starting shipping"

dnf install mysql -y &>>$LOG_FILE
validate $? "installing mysql client"   


mysql -h mysql.mitha.fun -uroot -pRoboShop@1 < /app/db/schema.sql
validate $? "loading shipping schema" 

mysql -h mysql.mitha.fun -uroot -pRoboShop@1 < /app/db/app-user.sql
validate $? "creating application user"

mysql -h mysql.mitha.fun -uroot -pRoboShop@1 < /app/db/master-data.sql
validate $? "loading shipping data"

systemctl restart shipping &>>$LOG_FILE
validate $? "restarting shipping"  
