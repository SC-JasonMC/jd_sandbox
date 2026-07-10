#!/bin/bash

#Upgrade the OS
sudo dnf upgrade -y

#Create Linux swap of 16GB (128X64=8GB(BS=128 is optimal for creation))
sudo dd if=/dev/zero of=/swapfile bs=128M count=64
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

#Add /usr/local/bin to root path
echo 'export PATH="/usr/local/bin:$PATH"' >> /root/.bashrc

#Install script and Prowler dependencies
sudo dnf install -y jq git pip openssl-devel bzip2-devel libffi-devel gcc git zlib-devel

#Replace the OS base awscli with the latest version
sudo yum remove awscli -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

sudo ln -s /usr/local/bin/aws /usr/bin/aws

#Clone Multi-Account-Security-Assessment Repo
cd /usr/local
git clone https://github.com/aws-samples/multi-account-security-assessment-via-prowler prowler

#Upgrade pip and install pipenv
cd /usr/local/prowler

#Install Prowler via pip3
pip install prowler==4.*

#Reinstall OS based Python modules altered during Prowler and dependency install
sudo dnf reinstall python3-colorama python3-dateutil -y

#Set script to be executable
chmod +x /usr/local/prowler/prowler_scan.sh

#Replace default script variable values in /usr/local/prowler/prowler_scan.sh with parameters configured during CFT deploy
#Note: This occurs ONCE during EC2 deployment and must be manually configured after deploy if additional tuning is required
#       Multiple individual sed commands used for readability
sed -i 's/PARALLELISM="12"/PARALLELISM="${parallelism}"/' /usr/local/prowler/prowler_scan.sh
sed -i 's/IAM_CROSS_ACCOUNT_ROLE="ProwlerExecRole"/IAM_CROSS_ACCOUNT_ROLE="${iam_role}"/' /usr/local/prowler/prowler_scan.sh
sed -i 's/S3_BUCKET="SetBucketName"/S3_BUCKET="${s3_bucket}"/' /usr/local/prowler/prowler_scan.sh
sed -i 's/FINDING_OUTPUT='--status FAIL'/FINDING_OUTPUT=${finding_output}/' /usr/local/prowler/prowler_scan.sh
sed -i 's/AWSACCOUNT_LIST="allaccounts"/AWSACCOUNT_LIST="${account_scope}"/' /usr/local/prowler/prowler_scan.sh
