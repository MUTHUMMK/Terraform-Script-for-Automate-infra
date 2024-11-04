#!/bin/bash

TARGET_GROUP_NAME="test"
INSTANCE_NAME="TF"

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

# REGISTER ALL EC2 INSTANCE IDS WITH THE TARGET GROUP
aws elbv2 register-targets \
    --region ap-south-1 \
    --target-group-arn "$TARGET_GROUP_ARN" \
    --targets $(for id in $EC2_IDS; do echo "Id=$id"; done)

echo "All instances tagged as '$INSTANCE_NAME' registered with target group."

###########################################################################################################################