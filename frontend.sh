#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(basename "$0" | cut -d "." -f1)
# directory that contains this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONGODB_HOST=mongodb.daws86s.fun
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log

mkdir -p "$LOGS_FOLDER"
echo "Script started executed at: $(date)" | tee -a "$LOG_FILE"

if [ "$USERID" -ne 0 ]; then
    echo "ERROR:: Please run this script with root privilege" | tee -a "$LOG_FILE"
    exit 1 # failure is other than 0
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ "$1" -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a "$LOG_FILE"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a "$LOG_FILE"
    fi
}

dnf module disable nginx -y &>>"$LOG_FILE"
dnf module enable nginx:1.24 -y &>>"$LOG_FILE"
dnf install nginx -y &>>"$LOG_FILE"
VALIDATE $? "Installing Nginx"

systemctl enable nginx  &>>"$LOG_FILE"
systemctl start nginx &>>"$LOG_FILE" || true
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>"$LOG_FILE"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>"$LOG_FILE"
cd /usr/share/nginx/html || exit 1
unzip -o /tmp/frontend.zip &>>"$LOG_FILE"
VALIDATE $? "Downloading frontend"

# Copy nginx.conf from the script directory; verify file exists
if [ -f "$SCRIPT_DIR/nginx.conf" ]; then
    cp -v "$SCRIPT_DIR/nginx.conf" /etc/nginx/nginx.conf &>>"$LOG_FILE"
    VALIDATE $? "Copying nginx.conf"
else
    echo "ERROR: $SCRIPT_DIR/nginx.conf not found" | tee -a "$LOG_FILE"
    exit 1
fi

# Test nginx configuration before restarting
nginx -t &>>"$LOG_FILE"
VALIDATE $? "Testing nginx configuration"

systemctl restart nginx &>>"$LOG_FILE" || true
VALIDATE $? "Restarting Nginx"