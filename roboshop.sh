#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0a2728062dcacf005"

for instance in $@
do
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t2.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

 if [ $instance -ne "frontend" ]; then
   Private_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
   echo "$instance : $Private_IP"

 else
   Public_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    echo "$instance : $Public_IP"
 fi

done

