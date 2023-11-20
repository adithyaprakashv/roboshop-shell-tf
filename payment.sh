#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi
VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

yum install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "Installing Python"

USER_ROBOSHOP=$(id roboshop)

if [ $? -ne 0 ];
then
    echo -e "$Y...USER roboshop is not present so creating now..$N"
    useradd roboshop &>>$LOGFILE
else
    echo -e "$G...USER roboshop is already present so skipping now.$N"
fi

#checking the user app directory 
#write a condition to check directory already exist or not

VALIDATE_APP_DIR=$(cd /app)
{
if [ $? -ne 0 ];
then
    echo -e " $Y /app directory not there so creating now $N"
    mkdir /app &>>$LOGFILE  
else
    echo -e "$G /app directory already present so skipping now $N"
fi
}

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "Downloading Artifact"

cd /app &>> $LOGFILE
VALIDATE $? "Moving app directory"

unzip /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "Unzipping Payment"

cd /app &>> $LOGFILE

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "Installing Dependencies"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>>$LOGFILE
VALIDATE $? "Copying Payment service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon-reload"

systemctl enable payment &>> $LOGFILE
VALIDATE $? "Enabling Payment"

systemctl start payment &>> $LOGFILE
VALIDATE $? "Starting Payment"
