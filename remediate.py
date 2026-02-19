import boto3

s3 = boto3.client('s3')

def lambda_handler(event, context):

    buckets = s3.list_buckets()['Buckets']

    for bucket in buckets:
        bucket_name = bucket['Name']
        print(f"Checking bucket: {bucket_name}")

        try:
            response = s3.get_public_access_block(Bucket=bucket_name)
            config = response['PublicAccessBlockConfiguration']

            if not all([
                config.get('BlockPublicAcls'),
                config.get('IgnorePublicAcls'),
                config.get('BlockPublicPolicy'),
                config.get('RestrictPublicBuckets')
            ]):
                print("Public block exists but not fully enabled. Fixing...")

                s3.put_public_access_block(
                    Bucket=bucket_name,
                    PublicAccessBlockConfiguration={
                        'BlockPublicAcls': True,
                        'IgnorePublicAcls': True,
                        'BlockPublicPolicy': True,
                        'RestrictPublicBuckets': True
                    }
                )

                print(f"Fixed bucket: {bucket_name}")

            else:
                print("Bucket fully protected.")

        except:
            print("No public block found. Fixing...")

            s3.put_public_access_block(
                Bucket=bucket_name,
                PublicAccessBlockConfiguration={
                    'BlockPublicAcls': True,
                    'IgnorePublicAcls': True,
                    'BlockPublicPolicy': True,
                    'RestrictPublicBuckets': True
                }
            )

            print(f"Fixed bucket: {bucket_name}")

    return "Scan complete"
