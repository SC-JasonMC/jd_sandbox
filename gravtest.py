import boto3

region = "eu-west-2"

def get_current_instance_details(instance_type):
    ec2_client = boto3.client('ec2', region_name=region)
    instance_data = ec2_client.describe_instance_types(
        InstanceTypes=[
            instance_type
        ]
    )
    return instance_data

test = get_current_instance_details(instance_type="t4g.small")

print(test)
