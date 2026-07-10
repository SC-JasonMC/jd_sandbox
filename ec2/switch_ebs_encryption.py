import boto3
import argparse

class GlobalData:
    def __init__(self, region_name, profile_name):
        session = boto3.Session(profile_name=profile_name)
        self.ec2 = session.client('ec2', region_name=region_name)
            
    def get_resource_name(self, resource_id):
        # Retrieve resource name
        return next((tag['Value'] for tag in resource_id.get('Tags', []) if tag['Key'] == 'Name'), 'NO_TAG')

    def describe_volumes(self):
            # Retrieve EC2 volume data
            return self.ec2.describe_volumes(
                 Filters=[
                    {
                    'Name': 'status',
                    'Values': ['in-use']
                    }
                 ]
            )

class Volume(GlobalData):
    def __init__(self, region_name, profile_name):
        super().__init__(region_name, profile_name)

    def get_volume_data(self):
            # Prepare to collect volume data
            volume_data = []
            ec2_volumes = self.describe_volumes()

            for volume in ec2_volumes['Volumes']:
                volume_id = volume.get('VolumeId')
                volume_name = self.get_resource_name(volume)
                volume_type = volume.get('VolumeType', 'N/A')
                volume_az = volume.get('AvailabilityZone', 'N/A')
                volume_size = volume.get('Size', 'N/A')
                volume_state = volume.get('State', 'N/A')
                volume_iops = volume.get('Iops', 'N/A')
                volume_throughput = volume.get('Throughput', 'N/A')
                volume_encrypted = volume.get('Encrypted', 'N/A')
                kms_key = volume.get('KmsKeyId')
                attachment_info = (volume.get('Attachments') or [{}])[0]
                attached_instance_id = attachment_info.get('InstanceId', 'N/A')
                attachment_device = attachment_info.get('Device', 'N/A')
                volume_tags = volume.get('Tags', 'N/A')


                # Append collected data to the volume_data list
                volume_data.append({
                    "volume_id": volume_id,
                    "volume_name": volume_name,
                    "type": volume_type,
                    "az": volume_az,
                    "size": volume_size,
                    "iops": volume_iops,
                    "throughput": volume_throughput,
                    "instance_id": attached_instance_id,
                    "device": attachment_device,
                    "encrypted": volume_encrypted,
                    "kms_key": kms_key
                })

            # Return the volume data for external handling
            return volume_data
    
    def create_volumes(self, snapshot_data, kms_key_id):
        print("\nCreating new volumes from snapshots... ")

        new_volume_data = []

        for snapshot in snapshot_data:
            params = {
                "SnapshotId": snapshot["snapshot_id"],
                "AvailabilityZone": snapshot["az"],
                "VolumeType": snapshot["type"],
                "Encrypted": True,
                "TagSpecifications": [
                    {
                        "ResourceType": "volume",
                        "Tags": [
                            {
                                "Key": "Name",
                                "Value": snapshot["volume_name"]
                            },
                            {
                                "Key": "SourceVolumeId",
                                "Value": snapshot["volume_id"]
                            },
                            {
                                "Key": "SourceSnapshotId",
                                "Value": snapshot["snapshot_id"]
                            },
                            {
                                "Key": "Purpose",
                                "Value": "EBS encryption migration"
                            }
                        ]
                    }
                ]
            }

            if kms_key_id:
                params["KmsKeyId"] = kms_key_id

            if snapshot["type"] in ["io1", "io2", "gp3"] and snapshot["iops"] != "N/A":
                params["Iops"] = snapshot["iops"]

            if snapshot["type"] == "gp3" and snapshot["throughput"] != "N/A":
                params["Throughput"] = snapshot["throughput"]

            response = self.ec2.create_volume(**params)

            new_volume_id = response["VolumeId"]

            new_volume_data.append({
                "old_volume_id": snapshot["volume_id"],
                "new_volume_id": new_volume_id,
                "snapshot_id": snapshot["snapshot_id"],
                "volume_name": snapshot["volume_name"],
                "instance_id": snapshot["instance_id"],
                "device": snapshot["device"],
                "az": snapshot["az"],
                "type": snapshot["type"],
            })

            print(f"\nCreated new volume {new_volume_id} from snapshot {snapshot['snapshot_id']} ")

        return new_volume_data
        
    def wait_for_new_volumes(self, new_volume_data):
        volume_ids = [volume["new_volume_id"] for volume in new_volume_data]

        if not volume_ids:
            print("\nNo volumes to wait for. ")
            return

        print(f"\nWaiting for new volumes to be available:\n{volume_ids} ")

        waiter = self.ec2.get_waiter("volume_available")
        waiter.wait(
            VolumeIds=volume_ids
        )

        print(f"\nAll volumes are available. ")

    def detach_old_volumes(self, volume_list):
        print(f"\nDetaching old volumes ")

        detached_volume_data = []

        for volume in volume_list:
            response = self.ec2.detach_volume(
                VolumeId=volume["volume_id"],
                InstanceId=volume["instance_id"],
                Device=volume["device"]
            )

            detached_volume_data.append(volume)

            print(f"\nDetaching old volume {volume['volume_id']} from {volume['instance_id']} as {volume['device']} ")

        return detached_volume_data

    def wait_for_volume_detach(self, volume_list):
        volume_ids = [volume['volume_id'] for volume in volume_list]

        if not volume_ids:
            print("\nNo volumes to wait for. ")
            return
        
        print(f"\nWaiting for old volumes to detach fully:\n{volume_ids} ")

        waiter = self.ec2.get_waiter("volume_available")
        waiter.wait(
            VolumeIds=volume_ids
        )
        
        print("\nOld volumes are detached. ")

    def attach_new_volumes(self, new_volume_list):
        print(f"\nAttaching new volumes. ")

        attached_volume_data = []

        for volume in new_volume_list:
            response = self.ec2.attach_volume(
                InstanceId=volume["instance_id"],
                VolumeId=volume["new_volume_id"],
                Device=volume["device"]
            )

            attached_volume_data.append(volume)

            print(
                f"\nAttaching new volume {volume['new_volume_id']} to {volume['instance_id']} as {volume['device']} ")

        return attached_volume_data
    
    def wait_for_volume_attach(self, new_volume_list):
        volume_ids = [volume["new_volume_id"] for volume in new_volume_list]

        if not volume_ids:
            print("\nNo volumes to wait for. ")
            return

        print(f"\nWaiting for new volumes to attach fully:\n{volume_ids} ")

        waiter = self.ec2.get_waiter("volume_in_use")
        waiter.wait(
            VolumeIds=volume_ids
        )

        print("\nNew volumes are attached. ")
                
    
class Instance(GlobalData):
    def __init__(self, region_name, profile_name):
        super().__init__(region_name, profile_name)
        self.instances = self.ec2.describe_instances()['Reservations']

    def get_running_instances(self, instance_ids):
        if not instance_ids:
            return []
        
        response = self.ec2.describe_instances(
            InstanceIds=instance_ids,
            Filters=[
                {
                    'Name': 'instance-state-name',
                    'Values': ['running']
                }
            ]
        )

        running_instances = []

        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                running_instances.append(instance['InstanceId'])

        return running_instances
    
    def stop_instances(self, running_instances):
        if not running_instances:
            print(f"\nNo running instances to stop. ")
            return None
        
        print(f"\nStopping instances... ")
        response = self.ec2.stop_instances(
            InstanceIds=running_instances,
            Hibernate=False,
            SkipOsShutdown=False,
            DryRun=False,
            Force=False
        )

        try:
            waiter = self.ec2.get_waiter('instance_stopped')
            waiter.wait(InstanceIds=running_instances)
            print(f"\nInstances Stopped ")
        except Exception as e:
            print(f"\nFailed waiting for instances to stop: {e} ")
            raise

        return response
    
    def start_instances(self, running_instances):
        if not running_instances:
            print(f"\nNo instances to start. ")
            return None
        
        print(f"\nStarting instances... ")
        response = self.ec2.start_instances(
            InstanceIds=running_instances,
        )

        try:
            waiter = self.ec2.get_waiter('instance_running')
            waiter.wait(InstanceIds=running_instances)
            print(f"\nInstances Running ")
        except Exception as e:
            print(f"\nFailed waiting for instances to start: {e} ")
            raise

        return response
    
class Snapshot(GlobalData):
    def __init__(self, region_name, profile_name):
        super().__init__(region_name, profile_name)

    def create_snapshots(self, volume_list):
        snapshot_data = []

        for volume in volume_list:
            volume_id = volume["volume_id"]
            volume_name = volume["volume_name"]

            response = self.ec2.create_snapshot(
                VolumeId=volume_id,
                Description=f"Snapshot for encryption migration of {volume_id} / {volume_name}",
                TagSpecifications=[
                    {
                        "ResourceType": "snapshot",
                        "Tags": [
                            {
                                "Key": "Name",
                                "Value": f"{volume_name}-pre-encryption"
                            },
                            {
                                "Key": "SourceVolumeId",
                                "Value": volume_id
                            },
                            {
                                "Key": "Purpose",
                                "Value": "EBS encryption migration"
                            }
                        ]
                    }
                ]
            )

            snapshot_id = response["SnapshotId"]

            snapshot_data.append({
                "volume_id": volume_id,
                "volume_name": volume_name,
                "snapshot_id": snapshot_id,
                "instance_id": volume["instance_id"],
                "device": volume["device"],
                "encrypted": volume["encrypted"],
                "az": volume["az"],
                "type": volume["type"],
                "size": volume["size"],
                "iops": volume["iops"],
                "throughput": volume["throughput"],
            })

            print(f"\nStarted snapshot {snapshot_id} for volume {volume_id} ")

        return snapshot_data

    def wait_for_snapshots(self, snapshot_data):
        snapshot_ids = [snap["snapshot_id"] for snap in snapshot_data]

        if not snapshot_ids:
            print("\nNo snapshots to wait for. ")
            return

        print(f"\nWaiting for snapshots to complete:\n{snapshot_ids} ")

        waiter = self.ec2.get_waiter("snapshot_completed")
        waiter.wait(
            SnapshotIds=snapshot_ids
        )

        print("\nAll snapshots completed. ")
    

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--profile_name")
    parser.add_argument("-r", "--region_name")
    parser.add_argument("-k", "--kms_key_id")
    parser.add_argument("--dry-run", action="store_true")
    

    args = parser.parse_args()

    volume = Volume(
        region_name=args.region_name,
        profile_name=args.profile_name,
    )

    raw_volume_list = volume.get_volume_data()

    for raw_volume in raw_volume_list:
        if raw_volume["kms_key"] == args.kms_key_id:
            print(f"\nSkipping {raw_volume['volume_id']} because it already uses the target KMS key ")

    volume_list = [v for v in raw_volume_list if v['kms_key'] != args.kms_key_id]

    if not volume_list:
        print("\nAll in-use volumes already use the target KMS key. Exiting. ")
        return
    else:
        print(f"\nVolume Data: \n{volume_list} ")

    # Get unique instance IDs from volume list
    instance_list = list(dict.fromkeys(vol['instance_id'] for vol in volume_list))

    instance = Instance(
        region_name=args.region_name,
        profile_name=args.profile_name
    )

    running_instances = instance.get_running_instances(instance_list)
    print(f"\nRunning instances:\n{running_instances} ")

    # response = instance.stop_instances(running_instances)

    if running_instances:
        instance.stop_instances(running_instances)
    
    snapshot = Snapshot(
        region_name=args.region_name,
        profile_name=args.profile_name
    )

    snapshot_list = snapshot.create_snapshots(volume_list)

    snapshot.wait_for_snapshots(snapshot_list)

    new_volume_list = volume.create_volumes(
        snapshot_data=snapshot_list,
        kms_key_id=args.kms_key_id
    )

    volume.wait_for_new_volumes(new_volume_list)

    if len(new_volume_list) != len(volume_list):
        raise RuntimeError("New volume count does not match old volume count. Aborting detach.")
    
    print("\nVolume replacement plan:")
    for vol in new_volume_list:
        print(f"\n{vol['old_volume_id']} -> {vol['new_volume_id']} on {vol['instance_id']} as {vol['device']} ")

    if args.dry_run:
        print("\nDry run enabled. Not stopping instances or modifying volumes. ")
        return

    detached_old_volumes = volume.detach_old_volumes(volume_list)

    volume.wait_for_volume_detach(detached_old_volumes)

    attached_new_volumes = volume.attach_new_volumes(new_volume_list)

    volume.wait_for_volume_attach(attached_new_volumes)

    if running_instances:
        instance.start_instances(running_instances)


if __name__ == "__main__":
    main()