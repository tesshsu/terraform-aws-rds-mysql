#!/bin/bash

# Update system
yum update -y
yum install -y gcc-c++ make git curl mysql

# Install NVM & Node.js
export NVM_DIR="/home/ec2-user/.nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash

# Ensure nvm is available in this script context
export NVM_DIR="/home/ec2-user/.nvm"
source $NVM_DIR/nvm.sh
nvm install 16
nvm alias default 16

# Ensure node and npm are in the path for all sessions
echo 'export NVM_DIR="$HOME/.nvm"' >> /home/ec2-user/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/ec2-user/.bashrc
echo 'nvm use default &> /dev/null' >> /home/ec2-user/.bashrc

# Install PM2 globally
npm install -g pm2

# Clone your app repository
cd /home/ec2-user
git clone https://github.com/tesshsu/todo-app.git
cd todo-app

# Install dependencies
npm install

# Start the app with PM2
pm2 start app.js --name "todoapp"

# Save the PM2 process list and configure startup script
pm2 save
pm2 startup systemd -u ec2-user --hp /home/ec2-user
