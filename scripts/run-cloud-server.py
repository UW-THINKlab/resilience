import boto3
import os
import argparse

sts = boto3.client('sts')

project_name = os.environ.get('TF_VAR_project_name', 'Support Sphere').lower().strip().replace(" ", "")
neighborhood = os.environ.get('TF_VAR_neighborhood', 'Laurelhurst').lower().strip().replace(" ", "")

resource_prefix = f'{project_name}-{neighborhood}'

deploy_role_arn = f'arn:aws:iam::871683513797:role/{resource_prefix}-scaling-role'
asg_name = f'{resource_prefix}-asg'

def start_session():
    response = sts.assume_role(
        RoleArn=deploy_role_arn,
        RoleSessionName='run-cloud-server',
    )

    return boto3.session.Session(
        aws_access_key_id=response['Credentials']['AccessKeyId'],
        aws_secret_access_key=response['Credentials']['SecretAccessKey'],
        aws_session_token=response['Credentials']['SessionToken'],
        region_name='us-west-2'
    )

        
def check_current_capacity(autoscaling):
    response = autoscaling.describe_auto_scaling_groups(
        AutoScalingGroupNames=[asg_name]
    )

    current_instances = len(response['AutoScalingGroups'][0]['Instances'])
    desired_capacity = response['AutoScalingGroups'][0]['DesiredCapacity']

    if current_instances == 1:
        if desired_capacity == 1:
            print('Current capacity is 1, and desired capacity is 1')
        else:
            print('Current capacity is 1, but desired capacity is 0.\nASG is in the process of scaling down')
    elif current_instances == 0:
        if desired_capacity == 1:
            print('Current capacity is 0, but desired capacity is 1.\nASG is in the process of scaling up')
        else:
            print('Current capacity is 0, and desired capacity is 0')

    return desired_capacity

def scale_up(autoscaling):
    if check_current_capacity(autoscaling=autoscaling) == 1:
        print('Server is already running')
        return
    
    response = autoscaling.set_desired_capacity(
        AutoScalingGroupName=asg_name,
        DesiredCapacity=1
    )
    print('Scaling up server, it may take a few minutes for the instance to start')


def scale_down(autoscaling):
    if check_current_capacity(autoscaling=autoscaling) == 0:
        print('Server is already stopped')
        return

    response = autoscaling.set_desired_capacity(
        AutoScalingGroupName=asg_name,
        DesiredCapacity=0
    )
    print('Scaling down server, it may take a few minutes for the instance to stop')



if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Run cloud server')
    parser.add_argument('--scale-up', action='store_true', help='Scale up the server by running 1 instance')
    parser.add_argument('--scale-down', action='store_true', help='Scale down the server having 0 instances running')

    args = parser.parse_args() 

    print('Assuming role')
    session = start_session()
    autoscaling = session.client('autoscaling')
    print('Role assumed')
    if args.scale_up:
        scale_up(autoscaling=autoscaling)
    elif args.scale_down:
        scale_down(autoscaling=autoscaling)
    