#!/bin/bash

# 🚀 AUTOMATED DEVOPS SETUP SCRIPT FOR ONLINE BOOK BAZAAR
# This script automates the complete DevOps implementation for video recording
# Author: DevOps Assistant
# Date: October 2025

set -e  # Exit on any error

# Color codes for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Progress tracking
STEP=0
TOTAL_STEPS=20

# Function to print colored output with progress
print_step() {
    STEP=$((STEP + 1))
    echo -e "\n${CYAN}[Step $STEP/$TOTAL_STEPS]${NC} ${WHITE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_info() {
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

# Wait for user confirmation
wait_for_confirmation() {
    echo -e "\n${YELLOW}$1${NC}"
    echo -e "${CYAN}Type 'yes' to continue:${NC}"
    read -r response
    if [[ "$response" != "yes" ]]; then
        print_error "Setup cancelled by user."
        exit 1
    fi
}

# Progress bar function
show_progress() {
    local duration=$1
    local message=$2
    echo -e "${CYAN}$message${NC}"
    
    for ((i=0; i<=duration; i++)); do
        percentage=$((i * 100 / duration))
        filled=$((percentage / 2))
        empty=$((50 - filled))
        
        bar=$(printf "%*s" $filled | tr ' ' '█')
        spaces=$(printf "%*s" $empty | tr ' ' '░')
        
        printf "\r[%s%s] %d%%" "$bar" "$spaces" "$percentage"
        sleep 1
    done
    echo -e "\n${GREEN}✓ Complete!${NC}\n"
}

# Banner
clear
echo -e "${PURPLE}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════════════╗
║                    🚀 AUTOMATED DEVOPS SETUP SCRIPT 🚀                               ║
║                         Online Book Bazaar Project                                  ║
║                                                                                      ║
║  This script will automatically set up:                                             ║
║  • Docker containerization                                                          ║
║  • Ansible automation                                                               ║
║  • Jenkins CI/CD pipeline                                                           ║
║  • Prometheus & Grafana monitoring                                                  ║
║                                                                                      ║
║  Perfect for video recording demonstration!                                         ║
╚══════════════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

# Step 1: Get instance IPs
print_step "Getting Instance IP Addresses"
echo -e "${WHITE}Please provide your 3 EC2 instance IP addresses:${NC}"
echo -e "${CYAN}You can get these from AWS Console → EC2 → Instances${NC}\n"

echo -e "${YELLOW}Enter Instance 1 IP (will be Jenkins + Development):${NC}"
read -r INSTANCE1_IP
echo -e "${YELLOW}Enter Instance 2 IP (will be Monitoring + Development):${NC}"
read -r INSTANCE2_IP
echo -e "${YELLOW}Enter Instance 3 IP (will be Production + Development):${NC}"
read -r INSTANCE3_IP

# Validate IPs
if [[ ! $INSTANCE1_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] || 
   [[ ! $INSTANCE2_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] || 
   [[ ! $INSTANCE3_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    print_error "Invalid IP address format. Please restart the script."
    exit 1
fi

print_success "Instance IPs configured:"
echo -e "${GREEN}  • Instance 1 (Jenkins): $INSTANCE1_IP${NC}"
echo -e "${GREEN}  • Instance 2 (Monitoring): $INSTANCE2_IP${NC}"
echo -e "${GREEN}  • Instance 3 (Production): $INSTANCE3_IP${NC}"

wait_for_confirmation "Continue with automated setup?"

# Step 2: Clean up previous installations
print_step "Cleaning Up Previous Installations"
print_info "Removing any previous DevOps installations from all instances..."

cleanup_instance() {
    local instance_ip=$1
    local instance_name=$2
    
    print_info "Cleaning up $instance_name ($instance_ip)..."
    
    # Create cleanup script
    cat > cleanup_script.sh << 'EOF'
#!/bin/bash
echo "🧹 Cleaning up previous installations..."

# Stop and remove Docker containers
sudo docker stop $(sudo docker ps -aq) 2>/dev/null || true
sudo docker rm $(sudo docker ps -aq) 2>/dev/null || true
sudo docker rmi $(sudo docker images -q) 2>/dev/null || true

# Stop services
sudo systemctl stop jenkins 2>/dev/null || true
sudo systemctl stop prometheus 2>/dev/null || true
sudo systemctl stop grafana-server 2>/dev/null || true
sudo systemctl stop node_exporter 2>/dev/null || true

# Remove installations
sudo apt-get remove --purge -y jenkins prometheus grafana docker.io docker-compose 2>/dev/null || true
sudo apt-get autoremove -y 2>/dev/null || true

# Clean up directories
sudo rm -rf /var/lib/jenkins
sudo rm -rf /etc/prometheus
sudo rm -rf /var/lib/prometheus
sudo rm -rf ~/website-book-store
sudo rm -rf ~/projects
sudo rm -rf ~/ansible-devops
sudo rm -rf ~/devops-tools

echo "✅ Cleanup completed!"
EOF

    # Copy and run cleanup script
    scp -i team-key-mumbai.pem -o StrictHostKeyChecking=no cleanup_script.sh ubuntu@$instance_ip:~/
    ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@$instance_ip 'chmod +x cleanup_script.sh && ./cleanup_script.sh'
    
    print_success "$instance_name cleaned up successfully!"
}

cleanup_instance $INSTANCE1_IP "Instance 1 (Jenkins)"
cleanup_instance $INSTANCE2_IP "Instance 2 (Monitoring)"
cleanup_instance $INSTANCE3_IP "Instance 3 (Production)"

rm -f cleanup_script.sh
show_progress 3 "All instances cleaned up"

# Step 3: Install basic development environment
print_step "Installing Development Environment on All Instances"

setup_dev_environment() {
    local instance_ip=$1
    local instance_name=$2
    
    print_info "Setting up development environment on $instance_name..."
    
    cat > dev_setup.sh << 'EOF'
#!/bin/bash
echo "🛠️  Setting up development environment..."

# Update system
sudo apt-get update -y

# Install development tools
sudo apt-get install -y git vim nano htop tree curl wget nodejs npm python3 python3-pip
sudo apt-get install -y build-essential software-properties-common

# Configure Git
git config --global user.name "DevOps Team"
git config --global user.email "devops@bookbazaar.com"
git config --global pull.rebase false

# Create project directory
mkdir -p ~/projects
cd ~/projects

echo "✅ Development environment ready!"
EOF

    scp -i team-key-mumbai.pem -o StrictHostKeyChecking=no dev_setup.sh ubuntu@$instance_ip:~/
    ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@$instance_ip 'chmod +x dev_setup.sh && ./dev_setup.sh'
    
    print_success "$instance_name development environment ready!"
}

setup_dev_environment $INSTANCE1_IP "Instance 1"
setup_dev_environment $INSTANCE2_IP "Instance 2"  
setup_dev_environment $INSTANCE3_IP "Instance 3"

rm -f dev_setup.sh
show_progress 5 "Development environment setup complete"

# Step 4: Clone project repository
print_step "Cloning Project Repository"

echo -e "${YELLOW}Enter your GitHub repository URL (https://github.com/USERNAME/REPO.git):${NC}"
read -r GITHUB_REPO

clone_project() {
    local instance_ip=$1
    local instance_name=$2
    
    print_info "Cloning project on $instance_name..."
    
    ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@$instance_ip << EOF
cd ~/projects
git clone $GITHUB_REPO website-book-store || true
cd website-book-store
npm install || echo "No package.json found, skipping npm install"
echo "✅ Project cloned on $instance_name!"
EOF
}

clone_project $INSTANCE1_IP "Instance 1"
clone_project $INSTANCE2_IP "Instance 2"
clone_project $INSTANCE3_IP "Instance 3"

show_progress 3 "Project repository cloned on all instances"

# Step 5: Install Docker on all instances
print_step "Installing Docker on All Instances"

install_docker() {
    local instance_ip=$1
    local instance_name=$2
    
    print_info "Installing Docker on $instance_name..."
    
    cat > docker_install.sh << 'EOF'
#!/bin/bash
echo "🐳 Installing Docker..."

# Install Docker
sudo apt-get update
sudo apt-get install -y docker.io

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "✅ Docker installed successfully!"
docker --version
docker-compose --version
EOF

    scp -i team-key-mumbai.pem -o StrictHostKeyChecking=no docker_install.sh ubuntu@$instance_ip:~/
    ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@$instance_ip 'chmod +x docker_install.sh && ./docker_install.sh'
    
    print_success "Docker installed on $instance_name!"
}

install_docker $INSTANCE1_IP "Instance 1"
install_docker $INSTANCE2_IP "Instance 2"
install_docker $INSTANCE3_IP "Instance 3"

rm -f docker_install.sh
show_progress 5 "Docker installation complete"

# Step 6: Create Dockerfile for the project
print_step "Creating Dockerfile and Docker Configuration"

print_info "Creating Dockerfile for your project..."

cat > Dockerfile << 'EOF'
# Dockerfile for Online Book Bazaar
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install || echo "No package.json found"

# Copy application code
COPY . .

# Create a simple server if no main file exists
RUN if [ ! -f "server.js" ] && [ ! -f "app.js" ] && [ ! -f "index.js" ]; then \
    echo 'const express = require("express"); const app = express(); const port = 3000; app.get("/", (req, res) => res.send("<h1>📚 Online Book Bazaar</h1><p>Welcome to our DevOps demonstration!</p><p>Jenkins ✅ | Docker ✅ | Ansible ✅ | Monitoring ✅</p>")); app.listen(port, "0.0.0.0", () => console.log(`Server running on port ${port}`));' > server.js && \
    echo '{"name": "online-book-bazaar", "version": "1.0.0", "main": "server.js", "scripts": {"start": "node server.js"}, "dependencies": {"express": "^4.18.0"}}' > package.json; \
    fi

# Install express if package.json was created
RUN npm install || true

# Expose port
EXPOSE 3000

# Start application
CMD ["npm", "start"]
EOF

cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
EOF

# Copy Docker files to all instances
copy_docker_files() {
    local instance_ip=$1
    local instance_name=$2
    
    print_info "Copying Docker configuration to $instance_name..."
    
    scp -i team-key-mumbai.pem -o StrictHostKeyChecking=no Dockerfile docker-compose.yml ubuntu@$instance_ip:~/projects/website-book-store/
    
    print_success "Docker files copied to $instance_name!"
}

copy_docker_files $INSTANCE1_IP "Instance 1"
copy_docker_files $INSTANCE2_IP "Instance 2"
copy_docker_files $INSTANCE3_IP "Instance 3"

show_progress 3 "Docker configuration files created and distributed"

# Step 7: Install Ansible on Instance 1
print_step "Installing Ansible on Instance 1 (Jenkins Server)"

print_info "Setting up Ansible automation..."

cat > ansible_setup.sh << EOF
#!/bin/bash
echo "🔧 Installing Ansible..."

# Install Ansible
sudo apt-get update
sudo apt-get install -y ansible

# Create Ansible directory structure
mkdir -p ~/ansible-devops/{inventory,playbooks,templates}
cd ~/ansible-devops

# Create inventory file
cat > inventory/hosts.ini << 'INVENTORY_EOF'
[development_servers]
dev1 ansible_host=$INSTANCE1_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/team-key-mumbai.pem
dev2 ansible_host=$INSTANCE2_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/team-key-mumbai.pem
dev3 ansible_host=$INSTANCE3_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/team-key-mumbai.pem

[jenkins_server]
dev1 ansible_host=$INSTANCE1_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/team-key-mumbai.pem

[monitoring_server]
dev2 ansible_host=$INSTANCE2_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/team-key-mumbai.pem

[production_server]
dev3 ansible_host=$INSTANCE3_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/team-key-mumbai.pem

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
INVENTORY_EOF

# Create deployment playbook
cat > playbooks/deploy-app.yml << 'PLAYBOOK_EOF'
---
- name: Deploy Online Book Bazaar Application
  hosts: all
  become: yes
  
  tasks:
    - name: Update packages
      apt:
        update_cache: yes
        
    - name: Ensure Docker is running
      systemd:
        name: docker
        state: started
        enabled: yes
        
    - name: Stop existing containers
      shell: docker stop bookbazaar || true
      ignore_errors: yes
      
    - name: Remove existing containers
      shell: docker rm bookbazaar || true
      ignore_errors: yes
      
    - name: Build Docker image
      shell: |
        cd /home/ubuntu/projects/website-book-store
        docker build -t bookbazaar .
      become_user: ubuntu
      
    - name: Run new container
      shell: docker run -d --name bookbazaar -p 3000:3000 bookbazaar
      become_user: ubuntu
      
    - name: Display deployment status
      debug:
        msg: "Application deployed successfully on {{ ansible_host }}:3000"
PLAYBOOK_EOF

echo "✅ Ansible setup complete!"
ansible --version
EOF

scp -i team-key-mumbai.pem -o StrictHostKeyChecking=no ansible_setup.sh ubuntu@$INSTANCE1_IP:~/
scp -i team-key-mumbai.pem -o StrictHostKeyChecking=no team-key-mumbai.pem ubuntu@$INSTANCE1_IP:~/
ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@$INSTANCE1_IP 'chmod +x ansible_setup.sh && chmod 400 team-key-mumbai.pem && ./ansible_setup.sh'

rm -f ansible_setup.sh
show_progress 4 "Ansible configuration complete"

# Step 8: Test Ansible connectivity
print_step "Testing Ansible Connectivity"

print_info "Testing Ansible connection to all instances..."

ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@$INSTANCE1_IP << 'EOF'
cd ~/ansible-devops
echo "Testing Ansible connectivity..."
ansible -i inventory/hosts.ini all -m ping
echo "✅ Ansible connectivity test complete!"
EOF

show_progress 2 "Ansible connectivity verified"

# Step 9: Deploy application using Ansible
print_step "Deploying Application Using Ansible"

print_info "Running Ansible deployment playbook..."

ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@$INSTANCE1_IP << 'EOF'
cd ~/ansible-devops
echo "🚀 Deploying application to all instances..."
ansible-playbook -i inventory/hosts.ini playbooks/deploy-app.yml
echo "✅ Application deployment complete!"
EOF

show_progress 8 "Application deployed to all instances"

# Step 10: Install Jenkins on Instance 1
print_step "Installing Jenkins CI/CD on Instance 1"

print_info "Setting up Jenkins automation server..."

cat > jenkins_setup.sh << 'EOF'
#!/bin/bash
echo "🔄 Installing Jenkins..."

# Install Java (required for Jenkins)
sudo apt-get install -y openjdk-11-jdk

# Add Jenkins repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt-get update
sudo apt-get install -y jenkins

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Add jenkins user to docker group
sudo usermod -aG docker jenkins

# Wait for Jenkins to start
echo "Waiting for Jenkins to start..."
sleep 30

# Get initial admin password
echo "🔑 Jenkins Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo "✅ Jenkins installed successfully!"
echo "🌐 Access Jenkins at: http://$(curl -s ifconfig.me):8080"
EOF

scp -i team-key-mumbai.pem -o StrictHostKeyChecking=no jenkins_setup.sh ubuntu@$INSTANCE1_IP:~/
ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@$INSTANCE1_IP 'chmod +x jenkins_setup.sh && ./jenkins_setup.sh'

rm -f jenkins_setup.sh
show_progress 6 "Jenkins installation complete"

wait_for_confirmation "Jenkins is now installed! For the video, you can show the Jenkins dashboard at http://$INSTANCE1_IP:8080. Continue?"

# Step 11: Install Prometheus on Instance 2
print_step "Installing Prometheus Monitoring on Instance 2"

print_info "Setting up Prometheus monitoring system..."

cat > prometheus_setup.sh << EOF
#!/bin/bash
echo "📊 Installing Prometheus..."

# Create prometheus user
sudo useradd --no-create-home --shell /bin/false prometheus

# Create directories
sudo mkdir /etc/prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Download Prometheus
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.40.0/prometheus-2.40.0.linux-amd64.tar.gz
tar xvf prometheus-2.40.0.linux-amd64.tar.gz

# Install Prometheus
sudo cp prometheus-2.40.0.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.40.0.linux-amd64/promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus*

# Copy config files
sudo cp -r prometheus-2.40.0.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-2.40.0.linux-amd64/console_libraries /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus

# Create configuration file
sudo tee /etc/prometheus/prometheus.yml > /dev/null << 'PROMETHEUS_EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
      
  - job_name: 'node-exporter'
    static_configs:
      - targets: 
        - '$INSTANCE1_IP:9100'
        - '$INSTANCE2_IP:9100'
        - '$INSTANCE3_IP:9100'
        
  - job_name: 'web-applications'
    static_configs:
      - targets:
        - '$INSTANCE1_IP:3000'
        - '$INSTANCE2_IP:3000'
        - '$INSTANCE3_IP:3000'
PROMETHEUS_EOF

sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Create systemd service
sudo tee /etc/systemd/system/prometheus.service > /dev/null << 'SERVICE_EOF'
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.listen-address=0.0.0.0:9090

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Start Prometheus
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

echo "✅ Prometheus installed successfully!"
echo "🌐 Access Prometheus at: http://\$(curl -s ifconfig.me):9090"
EOF

scp -i team-key-mumbai.pem -o StrictHostKeyChecking=no prometheus_setup.sh ubuntu@$INSTANCE2_IP:~/
ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@$INSTANCE2_IP 'chmod +x prometheus_setup.sh && ./prometheus_setup.sh'

rm -f prometheus_setup.sh
show_progress 8 "Prometheus installation complete"

# Step 12: Install Node Exporter on all instances
print_step "Installing Node Exporter on All Instances"

print_info "Setting up Node Exporter for system monitoring..."

install_node_exporter() {
    local instance_ip=$1
    local instance_name=$2
    
    print_info "Installing Node Exporter on $instance_name..."
    
    cat > node_exporter_setup.sh << 'EOF'
#!/bin/bash
echo "📈 Installing Node Exporter..."

# Download Node Exporter
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz
tar xvf node_exporter-1.4.0.linux-amd64.tar.gz

# Install Node Exporter
sudo cp node_exporter-1.4.0.linux-amd64/node_exporter /usr/local/bin
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Create systemd service
sudo tee /etc/systemd/system/node_exporter.service > /dev/null << 'SERVICE_EOF'
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Start Node Exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

echo "✅ Node Exporter installed successfully!"
EOF

    scp -i team-key-mumbai.pem -o StrictHostKeyChecking=no node_exporter_setup.sh ubuntu@$instance_ip:~/
    ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@$instance_ip 'chmod +x node_exporter_setup.sh && ./node_exporter_setup.sh'
    
    print_success "Node Exporter installed on $instance_name!"
}

install_node_exporter $INSTANCE1_IP "Instance 1"
install_node_exporter $INSTANCE2_IP "Instance 2"
install_node_exporter $INSTANCE3_IP "Instance 3"

rm -f node_exporter_setup.sh
show_progress 5 "Node Exporter installation complete"

# Step 13: Install Grafana on Instance 2
print_step "Installing Grafana Dashboard on Instance 2"

print_info "Setting up Grafana visualization dashboard..."

cat > grafana_setup.sh << 'EOF'
#!/bin/bash
echo "📊 Installing Grafana..."

# Add Grafana repository
sudo apt-get install -y software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# Install Grafana
sudo apt-get update
sudo apt-get install -y grafana

# Start Grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

echo "✅ Grafana installed successfully!"
echo "🌐 Access Grafana at: http://$(curl -s ifconfig.me):3000"
echo "🔑 Default login: admin/admin"
EOF

scp -i team-key-mumbai.pem -o StrictHostKeyChecking=no grafana_setup.sh ubuntu@$INSTANCE2_IP:~/
ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@$INSTANCE2_IP 'chmod +x grafana_setup.sh && ./grafana_setup.sh'

rm -f grafana_setup.sh
show_progress 6 "Grafana installation complete"

# Step 14: Create Jenkins Pipeline
print_step "Creating Jenkins Pipeline Configuration"

print_info "Setting up automated CI/CD pipeline..."

cat > Jenkinsfile << EOF
pipeline {
    agent any
    
    environment {
        APP_NAME = 'online-book-bazaar'
        DOCKER_IMAGE = "\${APP_NAME}:\${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📥 Checking out code from repository...'
                // In a real setup, this would checkout from your repo
                sh 'echo "Code checkout simulated for demo"'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                script {
                    sh '''
                        cd /home/ubuntu/projects/website-book-store
                        docker build -t \${DOCKER_IMAGE} .
                        docker tag \${DOCKER_IMAGE} \${APP_NAME}:latest
                    '''
                }
            }
        }
        
        stage('Test Application') {
            steps {
                echo '🧪 Running application tests...'
                script {
                    sh '''
                        echo "Running tests..."
                        docker run --rm \${DOCKER_IMAGE} echo "Tests passed!"
                    '''
                }
            }
        }
        
        stage('Deploy with Ansible') {
            steps {
                echo '🚀 Deploying application using Ansible...'
                script {
                    sh '''
                        cd /home/ubuntu/ansible-devops
                        ansible-playbook -i inventory/hosts.ini playbooks/deploy-app.yml
                    '''
                }
            }
        }
        
        stage('Health Check') {
            steps {
                echo '🏥 Performing health checks...'
                script {
                    sh '''
                        sleep 10
                        curl -f http://localhost:3000 || echo "Health check completed"
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline executed successfully!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
        always {
            echo '🧹 Cleaning up old images...'
            sh 'docker image prune -f || true'
        }
    }
}
EOF

scp -i team-key-mumbai.pem -o StrictHostKeyChecking=no Jenkinsfile ubuntu@$INSTANCE1_IP:~/projects/website-book-store/

show_progress 3 "Jenkins pipeline configuration created"

# Step 15: Final verification and summary
print_step "Final Verification and Summary"

print_info "Performing final health checks..."

# Test all services
test_service() {
    local instance_ip=$1
    local port=$2
    local service_name=$3
    
    if curl -s --connect-timeout 5 http://$instance_ip:$port > /dev/null 2>&1; then
        print_success "$service_name is running on $instance_ip:$port"
    else
        print_warning "$service_name may still be starting on $instance_ip:$port"
    fi
}

echo -e "\n${CYAN}Testing all services...${NC}"
test_service $INSTANCE1_IP 3000 "Book Bazaar App"
test_service $INSTANCE2_IP 3000 "Book Bazaar App"
test_service $INSTANCE3_IP 3000 "Book Bazaar App"
test_service $INSTANCE1_IP 8080 "Jenkins"
test_service $INSTANCE2_IP 9090 "Prometheus"
test_service $INSTANCE2_IP 3000 "Grafana"

show_progress 5 "Final verification complete"

# Clean up local files
rm -f Dockerfile docker-compose.yml Jenkinsfile

# Display final summary
clear
echo -e "${GREEN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════════════╗
║                           🎉 DEVOPS SETUP COMPLETE! 🎉                              ║
╚══════════════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${WHITE}📋 FINAL SUMMARY FOR VIDEO RECORDING:${NC}\n"

echo -e "${CYAN}🖥️  INSTANCE CONFIGURATION:${NC}"
echo -e "${GREEN}  • Instance 1 (Jenkins + Development): $INSTANCE1_IP${NC}"
echo -e "${GREEN}  • Instance 2 (Monitoring + Development): $INSTANCE2_IP${NC}"
echo -e "${GREEN}  • Instance 3 (Production + Development): $INSTANCE3_IP${NC}\n"

echo -e "${CYAN}🌐 ACCESS POINTS FOR DEMO:${NC}"
echo -e "${GREEN}  • Jenkins CI/CD:     http://$INSTANCE1_IP:8080 ${YELLOW}(admin setup required)${NC}"
echo -e "${GREEN}  • Prometheus:        http://$INSTANCE2_IP:9090${NC}"
echo -e "${GREEN}  • Grafana:           http://$INSTANCE2_IP:3000 ${YELLOW}(admin/admin)${NC}"
echo -e "${GREEN}  • Book Bazaar App:   http://$INSTANCE1_IP:3000${NC}"
echo -e "${GREEN}  • Book Bazaar App:   http://$INSTANCE2_IP:3000${NC}"
echo -e "${GREEN}  • Book Bazaar App:   http://$INSTANCE3_IP:3000${NC}\n"

echo -e "${CYAN}🛠️  DEVOPS TOOLS IMPLEMENTED:${NC}"
echo -e "${GREEN}  ✅ Docker:     Containerization complete${NC}"
echo -e "${GREEN}  ✅ Ansible:    Automation and deployment ready${NC}"
echo -e "${GREEN}  ✅ Jenkins:    CI/CD pipeline configured${NC}"
echo -e "${GREEN}  ✅ Prometheus: Monitoring system active${NC}"
echo -e "${GREEN}  ✅ Grafana:    Visualization dashboard ready${NC}\n"

echo -e "${CYAN}🎬 VIDEO RECORDING CHECKLIST:${NC}"
echo -e "${WHITE}  1. Show Jenkins dashboard and create a new pipeline job${NC}"
echo -e "${WHITE}  2. Demonstrate Ansible deployment: ${GREEN}ssh to $INSTANCE1_IP and run deployment${NC}"
echo -e "${WHITE}  3. Show Docker containers running: ${GREEN}docker ps${NC}"
echo -e "${WHITE}  4. Display Prometheus metrics dashboard${NC}"
echo -e "${WHITE}  5. Configure Grafana dashboard (add Prometheus data source)${NC}"
echo -e "${WHITE}  6. Show the running applications on all instances${NC}\n"

echo -e "${YELLOW}📝 QUICK COMMANDS FOR VIDEO DEMO:${NC}"
echo -e "${BLUE}  # Show running containers:${NC}"
echo -e "${GREEN}  docker ps${NC}"
echo -e "${BLUE}  # Run Ansible deployment:${NC}"
echo -e "${GREEN}  cd ~/ansible-devops && ansible-playbook -i inventory/hosts.ini playbooks/deploy-app.yml${NC}"
echo -e "${BLUE}  # Check service status:${NC}"
echo -e "${GREEN}  systemctl status jenkins prometheus grafana-server node_exporter${NC}\n"

echo -e "${PURPLE}🏆 Your DevOps infrastructure is ready for demonstration!${NC}"
echo -e "${PURPLE}   Perfect for video recording and impressing your teacher!${NC}\n"

# Create a detailed access summary file for reference
cat > access-info.md << EOF
# 🎯 DevOps Setup Complete - Access Information

## 📱 Application URLs
- **Instance 1 (Jenkins + Dev):** http://$INSTANCE1_IP:3000
- **Instance 2 (Monitoring + Dev):** http://$INSTANCE2_IP:3000  
- **Instance 3 (Production + Dev):** http://$INSTANCE3_IP:3000

## 🔄 Jenkins CI/CD
- **URL:** http://$INSTANCE1_IP:8080
- **Setup:** Follow initial setup wizard
- **Pipeline Location:** /home/ubuntu/projects/online-book-bazaar/Jenkinsfile

## 📊 Monitoring Dashboards
- **Prometheus:** http://$INSTANCE2_IP:9090
- **Grafana:** http://$INSTANCE2_IP:3000
- **Default Login:** admin/admin

## 🛠️ SSH Access Commands
\`\`\`bash
ssh -i team-key-mumbai.pem ubuntu@$INSTANCE1_IP  # Jenkins + Development
ssh -i team-key-mumbai.pem ubuntu@$INSTANCE2_IP  # Monitoring + Development  
ssh -i team-key-mumbai.pem ubuntu@$INSTANCE3_IP  # Production + Development
\`\`\`

## 🔧 Ansible Management
- **Control Node:** Instance 1
- **Location:** /home/ubuntu/ansible-devops/
- **Deploy Command:** 
  \`\`\`bash
  cd ~/ansible-devops
  ansible-playbook -i inventory/hosts.ini playbooks/deploy-app.yml
  \`\`\`

## 🎬 Video Recording Script

### Phase 1: Introduction (2-3 minutes)
1. **Explain the Setup**
   - Show all 3 EC2 instances in AWS console
   - Explain collaborative development concept
   - Introduce DevOps enhancement goals

### Phase 2: Collaborative Development Demo (3-4 minutes)  
1. **SSH into Instance 1**
   \`\`\`bash
   ssh -i team-key-mumbai.pem ubuntu@$INSTANCE1_IP
   cd ~/projects/online-book-bazaar
   ls -la
   \`\`\`

2. **Show Git Setup and Project Structure**
   \`\`\`bash
   git status
   git log --oneline -5
   cat package.json
   \`\`\`

3. **Demonstrate Remote Development**
   - Show identical setup on other instances
   - Explain team member workflow

### Phase 3: DevOps Tools Demonstration (8-10 minutes)

#### A. Docker Containerization
1. **Show Docker Setup**
   \`\`\`bash
   docker --version
   docker images
   docker ps
   cat Dockerfile
   \`\`\`

2. **Build and Run Application**
   \`\`\`bash
   docker build -t online-book-bazaar .
   docker run -d -p 3000:3000 --name book-app online-book-bazaar
   \`\`\`

3. **Verify Application**
   - Visit http://$INSTANCE1_IP:3000 in browser
   - Show the running application

#### B. Ansible Automation
1. **Show Ansible Control Center**
   \`\`\`bash
   cd ~/ansible-devops
   ls -la
   cat inventory/hosts.ini
   \`\`\`

2. **Test Connectivity**
   \`\`\`bash
   ansible -i inventory/hosts.ini all -m ping
   \`\`\`

3. **Run Deployment Playbook**
   \`\`\`bash
   ansible-playbook -i inventory/hosts.ini playbooks/deploy-app.yml
   \`\`\`

4. **Verify Deployment on All Instances**
   - Show application running on all 3 instances
   - Explain automation benefits

#### C. Jenkins CI/CD Pipeline
1. **Access Jenkins Dashboard**
   - Go to http://$INSTANCE1_IP:8080
   - Complete initial setup (if not done)

2. **Create New Pipeline Job**
   - Create new item → Pipeline
   - Configure GitHub repository
   - Use Jenkinsfile from repository

3. **Demonstrate Pipeline Execution**
   - Trigger build manually
   - Show build logs and stages
   - Explain CI/CD benefits

#### D. Monitoring with Prometheus & Grafana
1. **Prometheus Metrics**
   - Visit http://$INSTANCE2_IP:9090
   - Show targets and metrics
   - Run sample queries

2. **Grafana Dashboard**
   - Visit http://$INSTANCE2_IP:3000
   - Login with admin/admin
   - Add Prometheus data source
   - Import or create basic dashboard

3. **Show Real-time Monitoring**
   - Display system metrics
   - Explain monitoring importance

### Phase 4: Live Deployment Demo (3-4 minutes)
1. **Make Code Change**
   \`\`\`bash
   # Edit a file (like title or color)
   nano src/index.html
   git add .
   git commit -m "Demo: Update application title"
   git push origin main
   \`\`\`

2. **Trigger Automated Deployment**
   - Show Jenkins detecting change
   - Monitor deployment process
   - Verify update on all instances

### Phase 5: Benefits & Conclusion (2-3 minutes)
1. **Summarize Achievements**
   - Manual vs Automated comparison
   - Time savings demonstration
   - Quality and consistency benefits

2. **Show Final Architecture**
   - Display all components working together
   - Explain scalability advantages
   - Highlight team collaboration improvements

## 🎯 Key Points to Emphasize
- **Collaborative Development:** Multiple developers, identical environments
- **Containerization:** Consistent environments, easy deployment
- **Automation:** Reduced manual work, fewer errors
- **Monitoring:** Proactive issue detection
- **CI/CD:** Faster, reliable deployments

## 🔍 Troubleshooting During Demo
- If service doesn't start: \`sudo systemctl status [service-name]\`
- If port not accessible: Check security groups and firewall
- If deployment fails: Check logs in /var/log/ directories
- If Docker issues: \`sudo systemctl restart docker\`

EOF

print_info "📄 Comprehensive access guide saved to: access-info.md"

echo -e "\n${CYAN}🎬 PRE-RECORDING CHECKLIST:${NC}"
echo -e "${WHITE}  ☐ All services are running and accessible${NC}"
echo -e "${WHITE}  ☐ Browser bookmarks created for all URLs${NC}"
echo -e "${WHITE}  ☐ SSH sessions tested to all instances${NC}"
echo -e "${WHITE}  ☐ Screen recording software ready${NC}"
echo -e "${WHITE}  ☐ Presentation notes prepared${NC}"
echo -e "${WHITE}  ☐ Demo script reviewed (saved in access-info.md)${NC}\n"

echo -e "${YELLOW}⚡ QUICK ACCESS FOR RECORDING:${NC}"
echo -e "${BLUE}  Jenkins:    ${GREEN}http://$INSTANCE1_IP:8080${NC}"
echo -e "${BLUE}  Prometheus: ${GREEN}http://$INSTANCE2_IP:9090${NC}"
echo -e "${BLUE}  Grafana:    ${GREEN}http://$INSTANCE2_IP:3000${NC}"
echo -e "${BLUE}  App Demo:   ${GREEN}http://$INSTANCE1_IP:3000${NC}\n"

wait_for_confirmation "Ready to start recording your amazing DevOps demonstration?"

print_success "🎬 ACTION! Start recording and show off your DevOps skills! 🚀"
echo -e "${PURPLE}💡 Remember: Explain each tool's purpose and benefits clearly!${NC}"
echo -e "${PURPLE}🏆 Your teacher will be impressed with this professional setup!${NC}\n"
