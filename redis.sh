#1/bin/bash/
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell_script"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
DEST_PATH="/etc/redis/redis.conf"

PATH="/etc/redis/redis.conf

mkdir -p $LOG_FOLDER

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
    echo -e " you are not a root user "
    exit 1
else
    echo "you are root user"
fi

validate() {
    if [ $1 -ne 0 ]; then
        echo -e " $2 installation failed $R installation failed $N"
        exit 1
    else
        echo -e " installaltion $2 ----$G successfull $N"
    fi
}

dnf module disable redis -y &>>$LOG_FILE
validate $? "disabling reddis"

dnf module enable redis:7 -y &>>LOG_FILE
validate $? "enabling reddis"

dnf install redis -y &>>$LOG_FILE
validate $? "redis"


sed -i /127.0.0.1/0.0.0.0/ $DEST_PATH
validate $? "allowing remote connections"

sed -i /protected-mode yes/protected-mode no/ $DEST_PATH
validate $? "disabling protected mode"

systemctl enable redis &>>$LOG_FILE
validate $? "enabling redis"

sytemctl start reddis &>>$LOG_FILE
validate $? "starting redis"    