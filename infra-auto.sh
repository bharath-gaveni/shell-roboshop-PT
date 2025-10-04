#!/bin/bash
AMI_ID=ami-09c813fb71547fc4f
SG_ID=sg-0e84bdd3fbd61aac4
DNS_Name=bharathgaveni.fun
Host_zone=Z00567342XXYQ4M01AREL

for instance in "$@"
do
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type t3.micro \
        --security-group-ids $SG_ID \
        --count 1 \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
    --output text)
    
    if [ "$instance" != "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
        --output text)
        Record_Name=$instance.$DNS_Name
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)
        Record_Name=$DNS_Name
    fi
    
    echo "$instance:$IP"
    
    aws route53 change-resource-record-sets \
    --hosted-zone-id $Host_zone \
    --change-batch '{
        "Changes": [
        {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "'$Record_Name'",
                    "Type": "A",
                    "TTL": 1,
                    "ResourceRecords": [
                        {
                            "Value": "'$IP'"
                        }
                    ]
                }
            }
        ]
    }'
done







