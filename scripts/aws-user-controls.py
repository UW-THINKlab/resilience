import boto3
import argparse

iam = boto3.client('iam')

USER_GROUP_NAME = "ssec-eng"

def create_user(username: str):
    try:
        iam.create_user(
            UserName=username
        )
        print(f'User {username} created successfully')
    except iam.exceptions.EntityAlreadyExistsException:
        print(f'User {username} already exists')

def add_user_to_group(username: str):
    try:
        iam.add_user_to_group(
            UserName=username,
            GroupName=USER_GROUP_NAME
        )
        print(f'User {username} added to group {USER_GROUP_NAME}')
    except iam.exceptions.NoSuchEntityException:
        print(f'User {username} or group {USER_GROUP_NAME} does not exist')


def create_access_key(username: str):
    response = iam.create_access_key(
        UserName=username
    )

    access_key = response['AccessKey']
    print(f'Access key created for user {username}')
    print(f'Access key ID: {access_key["AccessKeyId"]}')
    print(f'Secret access key: {access_key["SecretAccessKey"]}\n')
    print('To safe these in a secure location, run the following commands:')
    print('mkdir ~/.aws')
    print(f'echo "[{username}]" >> ~/.aws/credentials')
    print(f'echo "aws_access_key_id = {access_key["AccessKeyId"]}" >> ~/.aws/credentials')
    print(f'echo "aws_secret_access_key = {access_key["SecretAccessKey"]}" >> ~/.aws/credentials')
    print()
    print('To use this profile, run the following commands:\n')
    print(f'echo "[profile {username}]" >> ~/.aws/config')
    print(f'echo "region = us-west-2" >> ~/.aws/config')
    print(f'echo "output = json" >> ~/.aws/config')
    print(f'echo "cli_pager =" >> ~/.aws/config')
    print()
    print('To use this profile, run the following command:')
    print(f'export AWS_PROFILE={username}')


def revoke_access_key(username: str):
    access_keys_response = iam.list_access_keys(
        UserName=username
    )

    for access_key in access_keys_response['AccessKeyMetadata']:
        iam.delete_access_key(
            UserName=username,
            AccessKeyId=access_key['AccessKeyId']
        )
        print(f'Access key {access_key["AccessKeyId"]} revoked for user {username}')


def remove_user(username: str):
    iam.remove_user_from_group(
        UserName=username,
        GroupName=USER_GROUP_NAME
    )
    print(f'User {username} removed from group {USER_GROUP_NAME}')

    iam.delete_user(
        UserName=username
    )
    print(f'User {username} removed successfully')

def list_users():
    group = iam.get_group(
        GroupName=USER_GROUP_NAME
    )

    for user in group['Users']:
        print(user['UserName'])
        access_keys_response = iam.list_access_keys(
            UserName=user['UserName']
        )
        for access_key in access_keys_response['AccessKeyMetadata']:
            print(f'  Access key ID: {access_key["AccessKeyId"]}')
            print(f'    Status: {access_key["Status"]}')
            print(f'    Created: {access_key["CreateDate"]}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Controls for AWS users. Meant to be run by the account owner or admin to grant limited access to other users for what\'s needed for Support Sphere operational work.')
    parser.add_argument('action', choices=['add', 'remove', 'rotate', 'list'], help='Action to take. Add a user, remove a user, or rotate an existing user\'s access key')
    parser.add_argument('-u', '--username', type=str, help='Name for the new user, will become <name>-assumer')
    args = parser.parse_args()

    if args.action == 'list':
        list_users()
        exit(0)

    username = args.username + '-assumer'

    if args.action == 'add':
        create_user(username)
        add_user_to_group(username)
        create_access_key(username)
    elif args.action == 'remove':
        revoke_access_key(username)
        remove_user(username)
    elif args.action == 'rotate':
        revoke_access_key(username)
        create_access_key(username)
    elif args.action == 'list':
        list_users()