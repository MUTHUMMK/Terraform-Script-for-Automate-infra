#!/bin/bash

# SET INSTANCE NAME (filter for instances with 'Name' tag as 'TEST')
INSTANCE_NAME="TF"
TARGET_GROUP_NAME="test"

# GET THE ARN ID IN TARGET GROUP
TARGET_GROUP_ARN=$(aws elbv2 describe-target-groups \
    --region ap-south-1 \
    --names "$TARGET_GROUP_NAME" \
    --query 'TargetGroups[*].TargetGroupArn' \
    --output text)

# GET ALL EC2 INSTANCE IDS WITH THE NAME TAG 'TEST'
EC2_IDS=$(aws ec2 describe-instances \
    --region ap-south-1 \
    --filters "Name=tag:Name,Values=$INSTANCE_NAME" "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[*].InstanceId" \
    --output text)


# DEREGISTER RUNNING INSTANCES FROM TARGET GROUP
aws elbv2 deregister-targets \
    --region ap-south-1 \
    --target-group-arn "$TARGET_GROUP_ARN" \
    --targets $(for id in $EC2_IDS; do echo "Id=$id"; done)

echo "Deregistered running instances: $EC2_IDS"


###########################################################################################################################



