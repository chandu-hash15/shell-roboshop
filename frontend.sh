#!/bin/bash
R="/e[31m"
G="/e[32m"
Y="/e[33m"
N="/e[0m"
LOG_FOLDER="/var/Log/shell_roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR="pwd"

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


dnf module list nginx -y &>>$LOG_FILE
validate $? "nginx module list"

dnf module disable nginx -y &>>$LOG_FILE
validate $? "disabling nginx module"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
validate $? "enabling nginx 1.24 module"

dnf install nginx -y &>>$LOG_FILE
validate $? "nginx installation"

systemctl enable nginx &>>$LOG_FILE
validate $? "enabling nginx"

systemctl start nginx &>>$LOG_FILE
validate $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
validate $? "removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
validate $? "downloading frontend content"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOG_FILE

validate $? "extracting frontend content"

cp "$SCRIPT_DIR nginx.conf" /etc/nginx/nginx.conf
validate $? "copying nginx configuration file" 

systemctl restart nginx &>>$LOG_FILE
validate $? "restarting nginx"

