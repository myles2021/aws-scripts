##### AWS Cloud Watch Sample Alarm when CPU exceeds 70 % #####

sudo apt update -y && sudo apt install curl unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws configure
aws ec2 run-instances --image-id ami-(number) --count 1 --instance-type t2.micro --key-name (pem file)

# Create topic
aws sns create-topic --name sample-alarm-topic-myles

# Note down the topic ARN - i.e: arn:aws:sns:eu-west-2:#############:sample-alarm-topic-myles

# Create subscription
aws sns subscribe --topic-arn (your topic arn) --protocol email --notification-endpoint (your email address)

# Create your alarm
aws cloudwatch put-metric-alarm --alarm-name sample-alarm-topic-myles --alarm-description "Myles Sample Alarm when CPU exceeds 70 %" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 70 --unit Percent --comparison-operator GreaterThanThreshold --dimensions "Name=InstanceId,Value=(your instance id)" --evaluation-periods 2 --alarm-actions (your topic arn)

# A new instance has been made, ssh into the ec2 and run the following
sudo yum update -y
sudo amazon-linux-extras install epel -y
sudo yum install stress -y
sudo stress --cpu 8 --timeout 600

# Create policy
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
cat << EOF > assume-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${ACCOUNT_ID}:root",
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

# Create role on new policy
aws iam create-role --role-name ec2-cloudwatch-role --assume-role-policy-document file://assume-policy.json

# Attach policy to role
aws iam attach-role-policy --role-name ec2-cloudwatch-role --policy-arn arn:aws:iam::aws:policy/CloudWatchFullAccess

# Create instance profile
aws iam create-instance-profile --instance-profile-name EC2CWNEW

# Add role to instance profile
aws iam add-role-to-instance-profile --instance-profile-name EC2CWNEW --role-name ec2-cloudwatch-role

# Attach role to instance
aws ec2 associate-iam-instance-profile --iam-instance-profile Name=EC2CWNEW --instance-id (your instance id)


# Customize the metrics, as the default metrics are not so useful:

# Install dependencies
sudo yum update -y
sudo yum install -y perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https perl-Digest-SHA.x86_64 unzip

# Download cloudwatch agent zip file
cd /home/ec2-user/
curl https://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.2.zip -O

# Extract zip file
unzip CloudWatchMonitoringScripts-1.2.2.zip
rm -rf CloudWatchMonitoringScripts-1.2.2.zip

# Push custom metrics to CloudWatch
/home/ec2-user/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-avail

# This will return a successful message stating metric has been reported.
# Navigate to the CloudWatch metrics and you should see a Custom Namespace called "System/linux". If you go on in there -> InstanceId, there should be a list of metric names. This will show a single data point as we only sent one metric up.


# Clean up your AWS environment.

# Terminate EC2 instance
aws ec2 terminate-instances --instance-ids (instance id)

# Detaching IAM role
aws iam detach-role-policy --role-name ec2-cloudwatch-role --policy-arn arn:aws:iam::aws:policy/CloudWatchFullAccess

# Removing Role from instance profile
aws iam remove-role-from-instance-profile --instance-profile-name EC2CWNEW --role-name ec2-cloudwatch-role

# Deleting IAM Role
aws iam delete-role --role-name ec2-cloudwatch-role

# Unsubscribe from topic
aws sns list-subscriptions
aws sns unsubscribe --subscription-arn (subscription-arn id)

# Delete topic
aws sns delete-topic --topic-arn (topic arn id)

# Delete alarm
aws cloudwatch delete-alarms --alarm-names sample-alarm-topic-myles
