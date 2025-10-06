#!/bin/bash

# Clean up Jenkins completely from all instances
# Usage: ./cleanup-jenkins.sh

set -e

# Get instance IPs from Terraform
INSTANCE_IPS=$(terraform output -json instance_public_ips | jq -r '.[]')
IPS_ARRAY=($INSTANCE_IPS)
INSTANCE2_IP=${IPS_ARRAY[1]}

echo "Cleaning up Jenkins on $INSTANCE2_IP..."

# Function to run command on remote instance
run_remote() {
    local ip=$1
    local command=$2
    ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@$ip "$command"
}

# Completely remove Jenkins and all configurations
run_remote $INSTANCE2_IP "
    echo 'Stopping and removing Jenkins...'
    sudo systemctl stop jenkins 2>/dev/null || true
    sudo systemctl disable jenkins 2>/dev/null || true
    
    # Force remove Jenkins package
    sudo dpkg --remove --force-remove-reinstreq jenkins 2>/dev/null || true
    sudo dpkg --purge jenkins 2>/dev/null || true
    DEBIAN_FRONTEND=noninteractive sudo apt-get purge -y jenkins 2>/dev/null || true
    DEBIAN_FRONTEND=noninteractive sudo apt-get autoremove -y 2>/dev/null || true
    
    # Remove all Jenkins files and configurations
    sudo rm -rf /var/lib/jenkins
    sudo rm -rf /etc/default/jenkins
    sudo rm -rf /etc/init.d/jenkins
    sudo rm -rf /etc/systemd/system/jenkins.service
    sudo rm -rf /usr/share/jenkins
    sudo rm -rf /var/cache/jenkins
    sudo rm -rf /var/log/jenkins
    
    # Remove Jenkins user
    sudo userdel jenkins 2>/dev/null || true
    sudo groupdel jenkins 2>/dev/null || true
    
    # Remove Jenkins repository configuration
    sudo rm -f /etc/apt/sources.list.d/jenkins.list
    sudo rm -f /usr/share/keyrings/jenkins-keyring.asc
    
    # Clean package manager
    sudo apt-get clean
    sudo apt-get update
    sudo systemctl daemon-reload
    
    echo 'Jenkins cleanup completed!'
"

echo "Jenkins cleanup completed on $INSTANCE2_IP"
