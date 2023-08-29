#! /bin/bash
set -e

#Parameter.. harap diganti
# ssm_cloudwatch_config="master_cloudwatch_config"

# Ouput all log
# exec > >(tee /var/log/user-data.log|logger -t user-data-extra -s 2>/dev/console) 2>&1

# Make sure we have all the latest updates when we launch this instance
sudo apt-get update -y
sudo apt-get install collectd -y
sudo apt-get upgrade -y

# Configure Cloudwatch agent
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# Use cloudwatch config from SSM
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c ssm:${ssm_cloudwatch_config} -s

echo 'Done initialization'
