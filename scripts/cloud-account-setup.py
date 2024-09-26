import boto3
import os

def sanitize(input):
    return input.lower().strip().replace(" ", "")

project_name = sanitize(os.environ.get('TF_VAR_project_name', 'Support Sphere'))
neighborhood = sanitize(os.environ.get('TF_VAR_neighborhood', 'Laurelhurst'))
account_id = os.environ.get('TF_VAR_account_id', '123456789012')

resource_prefix = f'{project_name}-{neighborhood}'

iam = boto3.client('iam')

def setup_s3_bucket():
    s3 = boto3.client('s3')

    bucket_name = f'{project_name}-{account_id}-opentofu-state'

    try:
        s3.create_bucket(
            Bucket=bucket_name,
            CreateBucketConfiguration={
                'LocationConstraint': 'us-west-2'
            },
            ACL='private'
        )
        print(f'Created bucket {bucket_name}')
    except s3.exceptions.BucketAlreadyExists:
        print(f'Bucket {bucket_name} already exists')
    except s3.exceptions.BucketAlreadyOwnedByYou:
        print(f'Bucket {bucket_name} already owned by you, continuing :)')
    except Exception as e:
        print(f'Error creating bucket {bucket_name}: {e}')

if __name__ == '__main__':
    # S3 bucket setup
    setup_s3_bucket()