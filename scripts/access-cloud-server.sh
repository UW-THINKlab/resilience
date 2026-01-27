#!/bin/bash

function sanitize() {
    echo $1 |  tr '[:upper:]' '[:lower:]' | tr -d ' '
}

export account_id=$(sanitize "$TF_VAR_account_id")
export project=$(sanitize "$TF_VAR_project_name")
export neighborhood=$(sanitize "$TF_VAR_neighborhood")

echo "Sourcing credentials"

export sts_output=$(aws sts assume-role \
--role-arn arn:aws:iam::$account_id:role/$project-$neighborhood-server-access-role \
--role-session-name access-cloud-server \
--output json \
)

export AWS_ACCESS_KEY_ID=$(echo $sts_output | jq -r ".Credentials.AccessKeyId")
export AWS_SECRET_ACCESS_KEY=$(echo $sts_output | jq -r ".Credentials.SecretAccessKey")
export AWS_SESSION_TOKEN=$(echo $sts_output | jq -r ".Credentials.SessionToken")

echo "Getting instance ID"

export instance_id=$(aws ec2 describe-instances \
--region us-west-2 \
--filters Name=tag:Project,Values='Support Sphere' \
Name=instance-state-name,Values=running \
--query "Reservations[*].Instances[*].[InstanceId]" \
--output text \
)

if [[ -z $instance_id ]]; then
    echo "No running instances found."
    echo "You can start the server by running the following command:"
    echo "   pixi run cloud-server-run"
    echo "Then try this script again."
    echo "If you've already started a server, it can take a few minutes for it to be ready to accept connections."
    echo "Exiting..."
    exit 1
fi

echo "Starting session with instance $instance_id"

aws ssm start-session \
--document-name AWS-StartInteractiveCommand \
--parameters command="cd ~ && bash -l" \
--target $instance_id