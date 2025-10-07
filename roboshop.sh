#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0a2728062dcacf005"
ZONE_ID="Z00484781U0O1QG6VX0D8"
Domain_Name="mitha.fun"
for instance in $@
do
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t2.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

 if [ $instance -ne "frontend" ]; then
   IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
   RECORD_NAME="$instance.$Domain_Name"

 else
   IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    RECORD_NAME="$Domain_Name" 
 fi
 echo "$instance : $IP"

aws route53 change-resource-record-sets \
  --hosted-zone-id "$ZONE_ID" \
  --change-batch '{
    "Comment": "Updating record set",
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'"$RECORD_NAME"'",
          "Type": "A",
          "TTL": 100,
          "ResourceRecords": [
            {
              "Value": "'"$IP"'"
            }
          ]
        }
      }
    ]
  }




done

