import boto3
import csv


csv_path = 'C:\\git\\softcat\\aws-tooling\\aws_describe\\python\\output\\ec2_instance_combined.csv'

ec2 = boto3.resource('ec2')

with open(csv_path, mode='r') as file:
   csv_reader = csv.DictReader(file)
   for row in csv_reader:
        session = boto3.Session(profile_name=row['Profile'])
        ec2 = session.resource('ec2', region_name='eu-west-1')

        ec2.Instance(row['ID']).modify_attribute(
            DisableApiTermination={'Value': True}
    )
        
# Adding text to test state machine.

# Second attempt to trigger eventbridge.