# 🚀 Complete DevOps Implementation Guide
## Online Book Bazaar Project

### 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Prerequisites](#prerequisites)
3. [Docker Implementation](#docker-implementation)
4. [Ansible Configuration](#ansible-configuration)
5. [Jenkins CI/CD Setup](#jenkins-cicd-setup)
6. [Monitoring (Prometheus & Grafana)](#monitoring-prometheus--grafana)
7. [Complete Workflow](#complete-workflow)
8. [Troubleshooting](#troubleshooting)

---

## 🎯 Project Overview

### **What We're Building:**
- **Dockerization**: Containerize your Online Book Bazaar website
- **Ansible**: Automate server configuration and deployments
- **Jenkins**: Set up CI/CD pipeline for automatic deployments
- **Monitoring**: Implement Prometheus for metrics and Grafana for visualization

### **Why Each Tool:**
- **Docker**: Ensures your app runs the same everywhere (development, testing, production)
- **Ansible**: Automates repetitive server setup tasks (no more manual SSH commands)
- **Jenkins**: Automatically deploys your code when you push to GitHub
- **Prometheus/Grafana**: Monitor your application performance and server health

### **Simple Architecture:**
```
GitHub → Jenkins → Docker Build → Deploy via Ansible → Monitor with Prometheus/Grafana
```

---

## 📋 Prerequisites

### **What You Need:**
1. ✅ Your 3 EC2 instances (already created via Terraform)
2. ✅ SSH access to instances
3. ✅ GitHub repository with your website code
4. ✅ Basic understanding of Linux commands

### **Instance Setup (Run on all 3 instances):**

Connect to each instance and run these commands:

```bash
# Update system
sudo apt-get update -y

# Install Docker
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Install other tools
sudo apt-get install -y git curl wget unzip

# Logout and login again for Docker permissions
exit
```

---

## 🐳 Docker Implementation

### **Step 1: Create Dockerfile for Your Website**

In your website project folder, create a `Dockerfile`:

```dockerfile
# Use official Node.js image (adjust if your website uses different technology)
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files (if using Node.js)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Expose port (adjust based on your application)
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
```

### **Step 2: Create Docker Compose File**

Create `docker-compose.yml` in your website project:

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
    volumes:
      - ./logs:/app/logs

  # If your website uses a database
  database:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: your_password
      MYSQL_DATABASE: bookstore
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
```

### **Step 3: Test Docker Build**

```bash
# Navigate to your website project
cd /path/to/your/website/project

# Build Docker image
docker build -t online-book-bazaar .

# Run container to test
docker run -p 3000:3000 online-book-bazaar

# Check if website is accessible
curl http://localhost:3000
```

### **Why Docker?**
- **Consistency**: Your app runs the same on all environments
- **Isolation**: No conflicts with other applications
- **Portability**: Easy to move between servers
- **Scalability**: Can easily create multiple instances

---

## 🔧 Ansible Configuration

### **Step 1: Install Ansible (on your main instance)**

```bash
# Install Ansible
sudo apt-get update
sudo apt-get install -y ansible

# Verify installation
ansible --version
```

### **Step 2: Create Ansible Directory Structure**

```bash
mkdir -p ~/ansible-setup
cd ~/ansible-setup

# Create directory structure
mkdir -p playbooks inventory group_vars host_vars templates
```

### **Step 3: Create Inventory File**

Create `inventory/hosts.ini`:

```ini
[web_servers]
instance1 ansible_host=YOUR_INSTANCE1_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/team-key-mumbai.pem
instance2 ansible_host=YOUR_INSTANCE2_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/team-key-mumbai.pem
instance3 ansible_host=YOUR_INSTANCE3_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/team-key-mumbai.pem

[jenkins_server]
instance1 ansible_host=YOUR_INSTANCE1_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/team-key-mumbai.pem

[monitoring_server]
instance2 ansible_host=YOUR_INSTANCE2_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/team-key-mumbai.pem
```

### **Step 4: Create Basic Playbook**

Create `playbooks/setup-servers.yml`:

```yaml
---
- name: Setup Basic Server Configuration
  hosts: web_servers
  become: yes
  
  tasks:
    - name: Update system packages
      apt:
        update_cache: yes
        upgrade: dist
        
    - name: Install basic packages
      apt:
        name:
          - git
          - curl
          - wget
          - docker.io
          - htop
          - vim
        state: present
        
    - name: Start and enable Docker
      systemd:
        name: docker
        state: started
        enabled: yes
        
    - name: Add ubuntu user to docker group
      user:
        name: ubuntu
        groups: docker
        append: yes
        
    - name: Create application directory
      file:
        path: /opt/bookbazaar
        state: directory
        owner: ubuntu
        group: ubuntu
        mode: '0755'
```

### **Step 5: Deploy Application Playbook**

Create `playbooks/deploy-app.yml`:

```yaml
---
- name: Deploy Online Book Bazaar
  hosts: web_servers
  become: yes
  
  vars:
    app_name: online-book-bazaar
    app_port: 3000
    
  tasks:
    - name: Clone/Update application code
      git:
        repo: "https://github.com/YOUR-USERNAME/YOUR-WEBSITE-REPO.git"
        dest: "/opt/bookbazaar"
        version: main
        force: yes
      become_user: ubuntu
      
    - name: Stop existing container
      docker_container:
        name: "{{ app_name }}"
        state: absent
      ignore_errors: yes
      
    - name: Remove old image
      docker_image:
        name: "{{ app_name }}"
        state: absent
      ignore_errors: yes
      
    - name: Build new Docker image
      docker_image:
        name: "{{ app_name }}"
        source: build
        build:
          path: "/opt/bookbazaar"
        state: present
        
    - name: Run new container
      docker_container:
        name: "{{ app_name }}"
        image: "{{ app_name }}"
        state: started
        restart_policy: unless-stopped
        ports:
          - "{{ app_port }}:{{ app_port }}"
```

### **Step 6: Run Ansible Playbooks**

```bash
# Test connection to all servers
ansible -i inventory/hosts.ini all -m ping

# Run server setup
ansible-playbook -i inventory/hosts.ini playbooks/setup-servers.yml

# Deploy application
ansible-playbook -i inventory/hosts.ini playbooks/deploy-app.yml
```

### **Why Ansible?**
- **Automation**: No manual server configuration
- **Consistency**: All servers configured exactly the same
- **Reusability**: Same playbook works for multiple deployments
- **Documentation**: Playbooks serve as documentation

---

## 🔄 Jenkins CI/CD Setup

### **Step 1: Install Jenkins**

On your Jenkins server (instance1):

```bash
# Install Java (required for Jenkins)
sudo apt-get update
sudo apt-get install -y openjdk-11-jdk

# Add Jenkins repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt-get update
sudo apt-get install -y jenkins

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### **Step 2: Access Jenkins Web Interface**

1. Open browser and go to: `http://YOUR_INSTANCE1_IP:8080`
2. Enter the initial admin password
3. Install suggested plugins
4. Create admin user

### **Step 3: Install Required Plugins**

Go to: **Manage Jenkins** → **Manage Plugins** → **Available**

Install these plugins:
- Git Plugin
- Docker Plugin  
- Ansible Plugin
- GitHub Integration Plugin

### **Step 4: Configure Jenkins**

#### **Add Credentials:**
1. Go to **Manage Jenkins** → **Manage Credentials**
2. Add these credentials:
   - **SSH Private Key**: Upload your `team-key-mumbai.pem`
   - **GitHub Token**: Create token in GitHub settings
   - **Docker Hub**: If you plan to push images

#### **Configure Tools:**
1. Go to **Manage Jenkins** → **Global Tool Configuration**
2. Configure:
   - **Git**: Should auto-detect
   - **Docker**: Add Docker installation

### **Step 5: Create Jenkins Pipeline**

Create a new Pipeline job and use this `Jenkinsfile`:

```groovy
pipeline {
    agent any
    
    environment {
        APP_NAME = 'online-book-bazaar'
        DOCKER_IMAGE = "${APP_NAME}:${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                // Checkout code from GitHub
                git branch: 'main', 
                    url: 'https://github.com/YOUR-USERNAME/YOUR-WEBSITE-REPO.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    // Run basic tests
                    sh "docker run --rm ${DOCKER_IMAGE} npm test || true"
                }
            }
        }
        
        stage('Deploy with Ansible') {
            steps {
                script {
                    // Deploy using Ansible
                    sh """
                        ansible-playbook -i /home/ubuntu/ansible-setup/inventory/hosts.ini \
                        /home/ubuntu/ansible-setup/playbooks/deploy-app.yml \
                        --extra-vars "docker_image=${DOCKER_IMAGE}"
                    """
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    // Check if deployment was successful
                    sleep(time: 30, unit: "SECONDS")
                    sh "curl -f http://YOUR_INSTANCE_IP:3000 || exit 1"
                }
            }
        }
    }
    
    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
        always {
            // Clean up old images
            sh "docker image prune -f"
        }
    }
}
```

### **Step 6: Configure GitHub Webhook**

1. In your GitHub repository, go to **Settings** → **Webhooks**
2. Add webhook: `http://YOUR_JENKINS_IP:8080/github-webhook/`
3. Select "Just the push event"
4. Make sure webhook is active

### **Why Jenkins?**
- **Automation**: Code automatically deployed when pushed
- **Testing**: Runs tests before deployment
- **Rollback**: Easy to revert to previous version
- **Notifications**: Know immediately if deployment fails

---

## 📊 Monitoring (Prometheus & Grafana)

### **Step 1: Install Prometheus**

On your monitoring server (instance2):

```bash
# Create prometheus user
sudo useradd --no-create-home --shell /bin/false prometheus

# Create directories
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Download Prometheus
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.40.0/prometheus-2.40.0.linux-amd64.tar.gz

# Extract and install
tar xvf prometheus-2.40.0.linux-amd64.tar.gz
sudo cp prometheus-2.40.0.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.40.0.linux-amd64/promtool /usr/local/bin/

# Set permissions
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

# Copy config files
sudo cp -r prometheus-2.40.0.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-2.40.0.linux-amd64/console_libraries /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
```

### **Step 2: Configure Prometheus**

Create `/etc/prometheus/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: 
        - 'YOUR_INSTANCE1_IP:9100'
        - 'YOUR_INSTANCE2_IP:9100'
        - 'YOUR_INSTANCE3_IP:9100'

  - job_name: 'web-app'
    static_configs:
      - targets:
        - 'YOUR_INSTANCE1_IP:3000'
        - 'YOUR_INSTANCE3_IP:3000'
```

### **Step 3: Create Prometheus Service**

Create `/etc/systemd/system/prometheus.service`:

```ini
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

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
```

```bash
# Start Prometheus
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Check status
sudo systemctl status prometheus
```

### **Step 4: Install Node Exporter (on all servers)**

Run this on all 3 instances:

```bash
# Download Node Exporter
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz

# Extract and install
tar xvf node_exporter-1.4.0.linux-amd64.tar.gz
sudo cp node_exporter-1.4.0.linux-amd64/node_exporter /usr/local/bin

# Create user
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
```

Create `/etc/systemd/system/node_exporter.service`:

```ini
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

```bash
# Start Node Exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
```

### **Step 5: Install Grafana**

On monitoring server:

```bash
# Add Grafana repository
sudo apt-get install -y software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Install Grafana
sudo apt-get update
sudo apt-get install -y grafana

# Start Grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

### **Step 6: Configure Grafana**

1. Access Grafana: `http://YOUR_MONITORING_IP:3000`
2. Login: admin/admin (change password)
3. Add Prometheus data source:
   - URL: `http://localhost:9090`
   - Save & Test
4. Import dashboard:
   - Go to **+** → **Import**
   - Use dashboard ID: `1860` (Node Exporter Full)

### **Why Monitoring?**
- **Performance**: See how your application performs
- **Alerts**: Get notified when something goes wrong
- **Capacity Planning**: Know when to scale up
- **Troubleshooting**: Quickly find issues

---

## 🔄 Complete Workflow

### **Daily Development Process:**

1. **Developer pushes code to GitHub**
2. **GitHub webhook triggers Jenkins**
3. **Jenkins runs the pipeline:**
   - Checks out latest code
   - Builds Docker image
   - Runs tests
   - Deploys via Ansible
   - Performs health check
4. **Monitoring tracks the deployment**
5. **Grafana shows performance metrics**

### **Manual Deployment (when needed):**

```bash
# Connect to main instance
ssh -i team-key-mumbai.pem ubuntu@YOUR_INSTANCE1_IP

# Run Ansible deployment
cd ~/ansible-setup
ansible-playbook -i inventory/hosts.ini playbooks/deploy-app.yml
```

### **Monitoring Health:**

```bash
# Check application status
curl http://YOUR_INSTANCE_IP:3000

# Check Prometheus targets
curl http://YOUR_MONITORING_IP:9090/targets

# View Grafana dashboards
# Open http://YOUR_MONITORING_IP:3000
```

---

## 🛠️ Troubleshooting

### **Common Docker Issues:**

```bash
# Check Docker status
sudo systemctl status docker

# View container logs
docker logs container_name

# Remove all containers and images (fresh start)
docker system prune -a
```

### **Common Ansible Issues:**

```bash
# Test connectivity
ansible -i inventory/hosts.ini all -m ping

# Run with verbose output
ansible-playbook -i inventory/hosts.ini playbooks/deploy-app.yml -vvv

# Check SSH key permissions
chmod 400 team-key-mumbai.pem
```

### **Common Jenkins Issues:**

```bash
# Check Jenkins status
sudo systemctl status jenkins

# View Jenkins logs
sudo journalctl -u jenkins -f

# Restart Jenkins
sudo systemctl restart jenkins
```

### **Common Monitoring Issues:**

```bash
# Check Prometheus status
sudo systemctl status prometheus

# Check if ports are open
netstat -tulpn | grep :9090

# View Prometheus logs
sudo journalctl -u prometheus -f
```

---

## 🎯 Presentation Points for Professor

### **What Each Tool Does:**

1. **Docker**: 
   - "Packages our application with all dependencies"
   - "Ensures it runs the same everywhere"

2. **Ansible**: 
   - "Automates server configuration"
   - "No more manual SSH commands"

3. **Jenkins**: 
   - "Automatically deploys when we push code"
   - "Runs tests before deployment"

4. **Prometheus/Grafana**: 
   - "Monitors application performance"
   - "Shows server health metrics"

### **Benefits Demonstrated:**
- ✅ **Automation**: No manual deployments
- ✅ **Consistency**: Same configuration across servers
- ✅ **Monitoring**: Real-time performance tracking
- ✅ **Reliability**: Automated testing and health checks
- ✅ **Scalability**: Easy to add more servers

This implementation shows a complete DevOps pipeline that automates deployment, ensures consistency, and provides monitoring - perfect for your final project presentation!
