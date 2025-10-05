#!/bin/bash

# Complete DevOps Deployment Script for Online Book Bazaar
# This script automates the entire DevOps setup process

echo "🚀 Starting Complete DevOps Setup for Online Book Bazaar"
echo "========================================================"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

# Check if we're in the correct directory
if [[ ! -f "main.tf" ]]; then
    print_error "Please run this script from the online-book-bazaar-infra directory"
    exit 1
fi

# Step 1: Verify AWS instances are running
print_status "Step 1: Verifying AWS instances..."
print_warning "Please ensure your Terraform infrastructure is deployed and instances are running"
echo "You can check this in the AWS Console: https://console.aws.amazon.com/ec2/"
read -p "Are your 3 EC2 instances running? (y/n): " instances_ready

if [[ $instances_ready != "y" && $instances_ready != "Y" ]]; then
    print_error "Please deploy your infrastructure first using Terraform Cloud"
    exit 1
fi

# Step 2: Get instance IPs
print_status "Step 2: Configure instance IP addresses..."
echo "Please get the public IP addresses of your instances from AWS Console"
read -p "Enter Instance 1 IP (for Jenkins): " instance1_ip
read -p "Enter Instance 2 IP (for Monitoring): " instance2_ip
read -p "Enter Instance 3 IP (for Web App): " instance3_ip

# Validate IP addresses
if [[ ! $instance1_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] || 
   [[ ! $instance2_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] || 
   [[ ! $instance3_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    print_error "Invalid IP address format"
    exit 1
fi

# Step 3: Update Ansible inventory
print_status "Step 3: Updating Ansible inventory with IP addresses..."
sed -i.bak "s/REPLACE_WITH_INSTANCE1_IP/$instance1_ip/g" ansible/inventory.ini
sed -i.bak "s/REPLACE_WITH_INSTANCE2_IP/$instance2_ip/g" ansible/inventory.ini
sed -i.bak "s/REPLACE_WITH_INSTANCE3_IP/$instance3_ip/g" ansible/inventory.ini

print_success "Ansible inventory updated"

# Step 4: Test connectivity
print_status "Step 4: Testing SSH connectivity to instances..."
if command -v ansible >/dev/null 2>&1; then
    cd ansible
    ansible -i inventory.ini all -m ping
    connectivity_test=$?
    cd ..
    
    if [[ $connectivity_test -eq 0 ]]; then
        print_success "All instances are reachable"
    else
        print_warning "Some instances may not be reachable. Please check SSH keys and security groups"
    fi
else
    print_warning "Ansible not installed. Will install during setup process"
fi

# Step 5: Run setup playbooks
print_status "Step 5: Starting automated setup process..."

echo "The following will be installed and configured:"
echo "- Docker on all instances"
echo "- Jenkins on Instance 1 ($instance1_ip)"
echo "- Prometheus & Grafana on Instance 2 ($instance2_ip)"
echo "- Application deployment configuration"
echo ""

read -p "Continue with automated setup? (y/n): " continue_setup

if [[ $continue_setup != "y" && $continue_setup != "Y" ]]; then
    print_warning "Setup cancelled. You can run individual components manually."
    exit 0
fi

# Step 6: Install Ansible if not present
if ! command -v ansible >/dev/null 2>&1; then
    print_status "Installing Ansible..."
    sudo apt-get update
    sudo apt-get install -y ansible
    print_success "Ansible installed"
fi

# Step 7: Run main setup playbook
print_status "Step 6: Setting up basic server configuration..."
cd ansible
ansible-playbook -i inventory.ini main-playbook.yml

if [[ $? -eq 0 ]]; then
    print_success "Basic server setup completed"
else
    print_error "Basic server setup failed"
    exit 1
fi

# Step 8: Setup Jenkins
print_status "Step 7: Installing Jenkins..."
ansible-playbook -i inventory.ini jenkins-playbook.yml

if [[ $? -eq 0 ]]; then
    print_success "Jenkins installation completed"
    echo "Jenkins is available at: http://$instance1_ip:8080"
else
    print_error "Jenkins installation failed"
fi

# Step 9: Setup monitoring
print_status "Step 8: Installing monitoring stack (Prometheus & Grafana)..."
ansible-playbook -i inventory.ini monitoring-playbook.yml

if [[ $? -eq 0 ]]; then
    print_success "Monitoring stack installation completed"
    echo "Prometheus is available at: http://$instance2_ip:9090"
    echo "Grafana is available at: http://$instance2_ip:3000"
else
    print_error "Monitoring stack installation failed"
fi

cd ..

# Step 10: Display access information
print_status "Step 9: Deployment Summary"
echo "=========================================="
echo "🎉 DevOps setup completed!"
echo ""
echo "📊 Access Points:"
echo "• Jenkins CI/CD: http://$instance1_ip:8080"
echo "• Prometheus: http://$instance2_ip:9090"
echo "• Grafana: http://$instance2_ip:3000 (admin/admin)"
echo "• Web App Instance: http://$instance3_ip:3000 (after deployment)"
echo ""
echo "🔑 Next Steps:"
echo "1. Complete Jenkins setup wizard in your browser"
echo "2. Configure GitHub webhook for automatic deployments"
echo "3. Import Grafana dashboard for monitoring"
echo "4. Deploy your application using: ansible-playbook -i ansible/inventory.ini ansible/deploy-production.yml"
echo ""
echo "📚 Documentation:"
echo "• Full guide: DEVOPS_IMPLEMENTATION_GUIDE.md"
echo "• Troubleshooting: Check the guide for common issues"
echo ""

# Step 11: Optional - Create summary file
cat > deployment_summary.txt << EOF
Online Book Bazaar - DevOps Deployment Summary
==============================================
Deployment Date: $(date)

Instance Configuration:
- Instance 1 (Jenkins): $instance1_ip
- Instance 2 (Monitoring): $instance2_ip  
- Instance 3 (Web App): $instance3_ip

Access URLs:
- Jenkins: http://$instance1_ip:8080
- Prometheus: http://$instance2_ip:9090
- Grafana: http://$instance2_ip:3000
- Application: http://$instance3_ip:3000

Credentials:
- Grafana: admin/admin (change on first login)
- Jenkins: Use initial admin password from setup

Next Steps:
1. Complete Jenkins setup wizard
2. Configure GitHub webhooks
3. Import Grafana monitoring dashboard
4. Deploy your application

EOF

print_success "Deployment summary saved to deployment_summary.txt"
print_success "🎉 Complete DevOps setup finished!"

echo ""
echo "Need help? Check the DEVOPS_IMPLEMENTATION_GUIDE.md file for detailed instructions."
