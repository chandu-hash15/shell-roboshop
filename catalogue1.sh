#!/bin/bash/

R="/e[31m"
G="/e[32m"
Y="/e[33m"
N="/e[0m"

LOG_FOLDER="/var/log/shell_script"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongo.mitha.fun 

trap 'echo "There is an error in $LINENO, Command: $BASH_COMMAND"' ERRs

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
    echo -e " you are not a root user "
    exit 1
else
    echo "you are root user"
fi

mkdir -p $LOG_FOLDER




dnf module disable CVV nodejs -y &>>$LOG_FILE


dnf module enable nodejs:20 -y &>>$LOG_FILE


dnf install nodejs -y &>>$LOG_FILE


id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app


curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE


cd /app


rm -rf /app/*


unzip /tmp/catalogue.zip &>>$LOG_FILE

npm install &>>$LOG_FILE



cp  $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>>$LOG_FILE


systemctl daemon-reload

systemctl enable catalogue &>>$LOG_FILE
  

systemctl start catalogue &>>$LOG_FILE


cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE  

dnf install mongodb-mongosh -y &>>$LOG_FILE


mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
