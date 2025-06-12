#!/bin/bash
yum update -y
yum install -y mysql git nodejs npm

# Install Docker for containerized apps
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Create app directory
mkdir -p /home/ec2-user/todoapp
chown ec2-user:ec2-user /home/ec2-user/todoapp

# Test MySQL connection
mysql -h ${rds_endpoint} -u ${db_username} -p${db_password} -e "SHOW DATABASES;"

# Install PM2 for Node.js app management
npm install -g pm2
