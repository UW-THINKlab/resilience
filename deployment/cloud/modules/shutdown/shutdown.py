'''TODO DOCSTRING'''

import boto3
import os


def lambda_handler(event, context):
    autoscaling_client = boto3.client('autoscaling')

    asg_name = os.environ.get('ASG_NAME')

    response = autoscaling_client.set_desired_capacity(
        AutoScalingGroupName=asg_name,
        DesiredCapacity=0,
        HonorCooldown=True
    )
    return 'Instance stopped ' + response