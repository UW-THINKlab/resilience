import boto3
import os

def sanitize(input):
    return input.lower().strip().replace(" ", "")

project_name = sanitize(os.environ.get('TF_VAR_project_name', 'Support Sphere'))
neighborhood = sanitize(os.environ.get('TF_VAR_neighborhood', 'Laurelhurst'))

resource_prefix = f'{project_name}-{neighborhood}'

USER_GROUP_NAME = "ssec-eng"
ACCOUNT_ID = "871683513797"

iam = boto3.client('iam')

def kms_key_exists(alias: str, region: str):
    kms = boto3.client('kms', region_name=region)
    try:
        kms.describe_key(
            KeyId=alias
        )
        return True
    except kms.exceptions.NotFoundException:
        return False
    

def grant_decrypt_permission_to_user_group(key_arn: str, region: str):
    iam.put_group_policy(
        GroupName=USER_GROUP_NAME,
        PolicyName=f'AllowDecryptKey{region}',
        PolicyDocument=f'''{{
            "Version": "2012-10-17",
            "Statement": [
                {{
                    "Effect": "Allow",
                    "Action": [
                        "kms:Decrypt"
                    ],
                    "Resource": "{key_arn}"
                }}
            ]
        }}'''
    )


def create_kms_key(region: str):
    kms = boto3.client('kms', region_name=region)

    key_alias_name = f'alias/{resource_prefix}-kms-key-{region}'

    if kms_key_exists(key_alias_name, region):
        print(f'Key already exists in {region}')
        return
    
    response = kms.create_key(
        Description='Key for encrypting and decrypting server config values for the Support Sphere project.',
        KeyUsage='ENCRYPT_DECRYPT',
        Origin='AWS_KMS',
        Tags=[
            {
                'TagKey': 'Project',
                'TagValue': project_name
            },
            {
                'TagKey': 'Neighborhood',
                'TagValue': neighborhood
            }
        ]
    )
    
    key_id = response['KeyMetadata']['KeyId']
    key_arn = response['KeyMetadata']['Arn']
    print(f'Created key {key_id} in {region} with ARN {key_arn}')

    kms.create_alias(
        AliasName=key_alias_name,
        TargetKeyId=key_id
    )

    grant_decrypt_permission_to_user_group(key_arn, region)

def setup_kms_keys():
    # Create key us-west-2 (Portland)
    create_kms_key('us-west-2')

    # Create key us-east-1 (Virginia)
    #    This is mainly a backup key in case the Portland region experiences issues
    create_kms_key('us-east-1')
    

if __name__ == '__main__':
    # The following TODOs will be implemented when working on the following issue 
    #    https://github.com/uw-ssec/post-disaster-comms/issues/63
    # Not doing this now because this work is focused on setting up a KMS key for the project

    # TODO: set up user group

    # TODO: set up no-trust user

    # TODO: set up deploy role

    # KMS key setup
    setup_kms_keys()