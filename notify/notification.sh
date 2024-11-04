#!/bin/bash

REGION="ap-south-1"
TAG_KEY="Name"
TAG_VALUE="terraform"
INSTANCE_NAME="TF"
INSTANCE_NAME_PERMANENT="LIVE_MOBILEAPP_BACKEND"

EC2_ID_LIVE=$(aws ec2 describe-instances \
    --region ap-south-1 \
    --filters "Name=tag:Name,Values=$INSTANCE_NAME_PERMANENT" "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[*].InstanceId" \
    --output text)

EC2_IDS=$(aws ec2 describe-instances \
    --region ap-south-1 \
    --filters "Name=tag:Name,Values=$INSTANCE_NAME" "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[*].InstanceId" \
    --output text)
    

# Get the SNS ARN
SNS_ARN=$(aws sns list-topics --region "$REGION" \
 --query "Topics[*].TopicArn" \
 --output text | tr '\t' '\n' | grep 'terraform$' | tail -n 1)

echo "$SNS_ARN"

# Set variables for SNS topic and email
SNS_TOPIC_ARN="$SNS_ARN"  # Replace with your SNS Topic ARN
EMAIL_SUBJECT_START="Terraform Start Notification"
EMAIL_SUBJECT_TERMINATE="Terraform Termination Notification"



# Function to send SNS email notification for Terraform Start
notify_terraform_start() {
local message="Terraform has started and created the following instances: $(date +'%Y-%m-%d %H:%M:%S')- LIVE API BACKEND Instance. 

PERMANENT LIVE API BACKEND ID:
"$EC2_ID_LIVE"

=============================================

TERRAFORM via CREATED NEW LIVE API BACKEND ID'S:
"$EC2_IDS" 

Please check the infrastructure status in your AWS account."
  
  echo "Notifying Terraform Start..."
  
  aws sns publish \
    --topic-arn "$SNS_TOPIC_ARN" \
    --message "$message" \
    --subject "$EMAIL_SUBJECT_START"
    
  if [ $? -eq 0 ]; then
    echo "Start notification sent successfully."
  else
    echo "Failed to send start notification."
  fi
}

# Function to send SNS email notification for Terraform Termination
notify_terraform_terminate() {
local message="Terraform has terminated the following instances:  $(date +'%Y-%m-%d %H:%M:%S') - LIVE API BACKEND Instance. 

PERMANENT LIVE API BACKEND ID:
"$EC2_ID_LIVE"

========================================

TERMINATE LIVE API BACKEND ID'S:  (below id's any display, kindly check the AWS EC2 infrastructure)
"$EC2_IDS" 

Please check the infrastructure status in your AWS account."
  
  echo "Notifying Terraform Termination..."
  
  aws sns publish \
    --topic-arn "$SNS_TOPIC_ARN" \
    --message "$message" \
    --subject "$EMAIL_SUBJECT_TERMINATE"
  
  if [ $? -eq 0 ]; then
    echo "Termination notification sent successfully."
  else
    echo "Failed to send termination notification."
  fi
}

# Check input arguments (start or terminate)
case "$1" in
  start)
    notify_terraform_start
    ;;
    
  terminate)
    notify_terraform_terminate
    ;;
    
  *)
    echo "Usage: $0 {start|terminate}"
    exit 1
    ;;
esac


# ./terraform-notify.sh start
# ./terraform-notify.sh terminate
