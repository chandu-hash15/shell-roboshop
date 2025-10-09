#!/bin/bash/

R="/e[31m"
G="/e[32m"
Y="/e[33m"
N="/e[0m"

LOG_FOLDER="/var/log/shell_script"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.mitha.fun 

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; thenecho -e " you are not a root user "
    exit 1
else
    echo "you are root user"
fi

mkdir -p $LOG_FOLDER

validate() {
    if [ $1 -ne 0 ]; then
        echo -e " installation $2 -----  $R failed $N"
        exit 1
    else
        echo -e " installation $2 ----- $G success $N"
    fi
}


dnf module disable nodejs -y &>>$LOG_FILE
validate $? "Disabling NodeJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE
validate $? "Enabling NodeJS 20"

dnf install nodejs -y &>>$LOG_FILE
validate $? "Installing NodeJS"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    validate $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app
validate $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
validate $? "Downloading catalogue application"

cd /app
validate $? "Changing to app directory"

rm -rf /app/*
validate $? "Removing existing code"

unzip /tmp/catalogue.zip &>>$LOG_FILE
validate $? "Extracting catalogue application"


npm install &>>$LOG_FILE
validate $? "Installing nodejs dependencies"


cp  $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>>$LOG_FILE
validate $? "Copying catalogue service file"

systemctl daemon-reload

systemctl enable catalogue &>>$LOG_FILE
validate $? "Enabling catalogue service"  

systemctl start catalogue &>>$LOG_FILE
validate $? "Starting catalogue service"    

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE  

dnf install mongodb-mongosh -y &>>$LOG_FILE
validate $? "Install MongoDB client"

mongosh --host MONGODB-SERVER-IPADDRESS </app/db/master-data.js &>>$LOG_FILE
validate $? "Load catalogue products"       