# 📚 Manual Step-by-Step DevOps Implementation
## Complete Guide for Online Book Bazaar Project

### 🎯 Overview
This guide will help you manually implement DevOps tools for your Online Book Bazaar project. We'll set up Docker, Ansible, Jenkins, and monitoring step by step, so you understand each component.

---

## 🏁 Getting Started

### **What You'll Build:**
1. **Docker**: Package your website in containers
2. **Ansible**: Automate server configuration  
3. **Jenkins**: Set up automatic deployments
4. **Monitoring**: Track performance with Prometheus & Grafana

### **Prerequisites Checklist:**
- ✅ 3 EC2 instances running (via Terraform)
- ✅ SSH access to all instances
- ✅ GitHub repository with your website
- ✅ Basic Linux command knowledge

---

## 📋 Step 1: Get Your Instance IPs

First, get the IP addresses of your EC2 instances:

1. **Go to AWS Console**: https://console.aws.amazon.com/ec2/
2. **Navigate to**: EC2 → Instances
3. **Find your instances**: `book-bazaar-instance-1`, `book-bazaar-instance-2`, `book-bazaar-instance-3`
4. **Note the Public IPv4 addresses**

**Write them down:**
- Instance 1 (Team Member 1): `_____________`
- Instance 2 (Team Member 2): `_____________`  
- Instance 3 (Team Member 3): `_____________`

## 🎯 **Implementation Strategy: Both Approaches**

We'll implement **BOTH approaches** to get maximum points:

### **Phase 1: Meet Teacher's Core Requirement ✅**
- Set up all 3 instances as **development environments**
- Demonstrate **collaborative team development**
- Show **Git workflow** and **remote development**
- **Duration**: 15 minutes of presentation

### **Phase 2: Add DevOps Enhancement 🚀**
- Transform the setup to include **DevOps tools**
- Instance 1: Development + **Jenkins CI/CD**
- Instance 2: Development + **Monitoring (Prometheus/Grafana)**
- Instance 3: Development + **Production Deployment**
- **Duration**: 15 minutes of presentation

### **Why This Approach Works:**
1. ✅ **Satisfies teacher's requirement** (collaborative development)
2. ✅ **Shows advanced skills** (DevOps automation)
3. ✅ **Demonstrates progression** (manual → automated)
4. ✅ **Real-world relevance** (how companies actually work)

**Let's implement both phases step by step!**

---

# 🏗️ PHASE 1: Collaborative Development Setup
## (Teacher's Core Requirement)

## 👥 Step 1A: Set Up Development Environment on All Instances

**Run this on ALL 3 instances to create identical development environments:**

```bash
# SSH to each instance
ssh -i team-key-mumbai.pem ubuntu@YOUR_INSTANCE_IP

# Update system
sudo apt-get update -y

# Install development tools for team collaboration
sudo apt-get install -y git vim nano htop tree curl wget nodejs npm python3 python3-pip

# Install additional useful tools
sudo apt-get install -y build-essential software-properties-common

# Verify installations
echo "=== Development Environment Setup ==="
node --version
npm --version
git --version
python3 --version

# Create project directory
mkdir -p ~/projects
cd ~/projects

echo "✅ Development environment ready for team member!"
```

## 👨‍💻 Step 1B: Configure Git for Each Team Member

**Each team member should configure Git with their own details:**

```bash
# Team Member 1 (on Instance 1)
git config --global user.name "Team Member 1"
git config --global user.email "member1@example.com"

# Team Member 2 (on Instance 2)  
git config --global user.name "Team Member 2"
git config --global user.email "member2@example.com"

# Team Member 3 (on Instance 3)
git config --global user.name "Team Member 3"
git config --global user.email "member3@example.com"
```

## 📂 Step 1C: Clone Project and Set Up Collaborative Workflow

**Each team member clones the project on their instance:**

```bash
# Clone your website repository
git clone https://github.com/YOUR-USERNAME/online-book-bazaar.git
cd online-book-bazaar

# Install project dependencies
npm install  # For Node.js projects
# OR
# pip install -r requirements.txt  # For Python projects

# Test the application
npm start
# OR  
# python3 app.py

# The app should be accessible at http://YOUR_INSTANCE_IP:3000
```

## 🔄 Step 1D: Daily Collaborative Development Workflow

**This demonstrates how team members collaborate:**

### **Team Member 1 - Adding Shopping Cart Feature:**
```bash
# Get latest changes
git pull origin main

# Create feature branch
git checkout -b feature/shopping-cart

# Make changes to code
nano src/components/ShoppingCart.js  # Example file

# Test changes
npm start

# Commit and push
git add .
git commit -m "Add shopping cart functionality"
git push origin feature/shopping-cart

# Create Pull Request on GitHub for team review
```

### **Team Member 2 - Adding User Authentication:**
```bash
# Get latest changes
git pull origin main

# Create feature branch  
git checkout -b feature/user-auth

# Make changes
nano src/auth/login.js  # Example file

# Test changes
npm start

# Commit and push
git add .
git commit -m "Add user authentication system"
git push origin feature/user-auth

# Create Pull Request on GitHub
```

### **Team Member 3 - Adding Book Search:**
```bash
# Get latest changes
git pull origin main

# Create feature branch
git checkout -b feature/book-search

# Make changes
nano src/search/BookSearch.js  # Example file

# Test changes
npm start

# Commit and push
git add .
git commit -m "Add book search functionality"  
git push origin feature/book-search

# Create Pull Request on GitHub
```

## ✅ Phase 1 Complete!

**At this point, you can demonstrate to your teacher:**
1. ✅ **3 instances for team development** (exactly what was requested)
2. ✅ **Remote development** (no local machines needed)
3. ✅ **Collaborative Git workflow** (branches, PRs, code review)
4. ✅ **Team coordination** (each member working on different features)

**This satisfies your teacher's core requirement!**

---

# 🚀 PHASE 2: DevOps Enhancement
## (Advanced Implementation)

Now we'll enhance the collaborative setup with DevOps tools while keeping the development functionality.

## 🐳 Step 2: Docker Implementation

### **2.1 Install Docker on All Instances**

**Connect to each instance and run:**

```bash
# SSH to each instance
ssh -i team-key-mumbai.pem ubuntu@YOUR_INSTANCE_IP

# Update system
sudo apt-get update -y

# Install Docker
sudo apt-get install -y docker.io

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version

# Logout and login again for group changes
exit
```

**Repeat this for all 3 instances.**

### **2.2 Prepare Your Website for Docker**

In your website project, create these files:

**Create `Dockerfile`:**
```dockerfile
# Use Node.js base image (adjust for your technology)
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Start application
CMD ["npm", "start"]
```

**Create `docker-compose.yml`:**
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
```

### **2.3 Test Docker Build**

```bash
# In your website directory
docker build -t online-book-bazaar .

# Test run
docker run -p 3000:3000 online-book-bazaar

# Check if it works
curl http://localhost:3000
```

**✅ Docker is now set up!**

---

## 🔧 Step 3: Ansible Configuration (DevOps Enhancement)

**Now we enhance the collaborative setup with automation tools:**

### **3.1 Install Ansible (on Instance 1 - Team Member 1 becomes DevOps lead)**

```bash
ssh -i team-key-mumbai.pem ubuntu@INSTANCE1_IP

# Install Ansible while keeping development environment
sudo apt-get update
sudo apt-get install -y ansible

# Verify installation
ansible --version

echo "✅ Instance 1 now serves as: Development Environment + DevOps Control Center"
```

### **3.2 Create Ansible Configuration for Managing All Instances**

```bash
# Create ansible directory (alongside existing project)
mkdir -p ~/ansible-devops
cd ~/ansible-devops

# Create required directories
mkdir -p inventory playbooks templates
```

**Create `inventory/hosts.ini`:**
```ini
# Ansible Inventory for DevOps Management
[development_servers]
dev1 ansible_host=INSTANCE1_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/team-key-mumbai.pem
dev2 ansible_host=INSTANCE2_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/team-key-mumbai.pem  
dev3 ansible_host=INSTANCE3_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/team-key-mumbai.pem

[jenkins_server]
dev1 ansible_host=INSTANCE1_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/team-key-mumbai.pem

[monitoring_server] 
dev2 ansible_host=INSTANCE2_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/team-key-mumbai.pem

[production_server]
dev3 ansible_host=INSTANCE3_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/team-key-mumbai.pem

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

**Replace INSTANCE1_IP, INSTANCE2_IP, INSTANCE3_IP with actual IPs**

### **3.3 Test Ansible Connectivity**

```bash
# Test connection to all development servers
ansible -i inventory/hosts.ini development_servers -m ping

# Expected output: SUCCESS for all instances
echo "✅ Ansible can now manage all team development instances!"
```

### **3.4 Create DevOps Enhancement Playbook**

**Create `playbooks/devops-setup.yml`:**
```yaml
---
- name: Enhance Development Servers with DevOps Tools
  hosts: development_servers
  become: yes
  
  tasks:
    - name: Update packages (maintain development environment)
      apt:
        update_cache: yes
        
    - name: Install DevOps tools alongside development tools
      apt:
        name:
          - git              # Already installed in Phase 1
          - curl             # Already installed in Phase 1
          - wget             # Already installed in Phase 1
          - docker.io        # New DevOps tool
          - htop             # Already installed in Phase 1
          - tree             # Already installed in Phase 1
        state: present
        
    - name: Start Docker (for containerization)
      systemd:
        name: docker
        state: started
        enabled: yes
        
    - name: Add team members to docker group
      user:
        name: ubuntu
        groups: docker
        append: yes
        
    - name: Create DevOps directories
      file:
        path: "/home/ubuntu/{{ item }}"
        state: directory
        owner: ubuntu
        group: ubuntu
        mode: '0755'
      loop:
        - devops-tools
        - deployment-scripts
        - monitoring-config
```

### **3.5 Run DevOps Enhancement Playbook**

```bash
# Enhance all instances with DevOps tools
ansible-playbook -i inventory/hosts.ini playbooks/devops-setup.yml

echo "✅ All instances now have: Development Environment + DevOps Tools!"
```

**✅ Ansible is now working!**

---

## 🔄 Step 4: Jenkins CI/CD Setup (Instance 1 Enhancement)

**Instance 1 now serves dual purpose: Team Member 1's Development + CI/CD Server**

### **4.1 Install Jenkins (on Instance 1 - alongside development environment)**

```bash
ssh -i team-key-mumbai.pem ubuntu@INSTANCE1_IP

# Install Java (required for Jenkins) - doesn't interfere with development
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

# Get initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo "✅ Instance 1 now runs: Development Environment + Jenkins CI/CD"
echo "✅ Team Member 1 can still develop while Jenkins handles automation"
```

**Copy the password shown - you'll need it!**

### **4.2 Complete Jenkins Setup**

1. **Open browser**: `http://INSTANCE1_IP:8080`
2. **Enter the password** you copied
3. **Install suggested plugins**
4. **Create admin user** (username: admin, password: admin123)
5. **Save and continue**

### **4.3 Install Required Jenkins Plugins**

1. Go to **Manage Jenkins** → **Manage Plugins**
2. Click **Available** tab
3. Search and install:
   - Git Plugin
   - Docker Plugin
   - Ansible Plugin
   - GitHub Integration Plugin
4. **Restart Jenkins**

### **4.4 Configure Jenkins Credentials**

1. Go to **Manage Jenkins** → **Manage Credentials**
2. Click **(global)** → **Add Credentials**
3. Add:
   - **Kind**: SSH Username with private key
   - **ID**: aws-key
   - **Username**: ubuntu
   - **Private Key**: Copy content of `team-key-mumbai.pem`

### **4.5 Create Your First Pipeline**

1. **New Item** → **Pipeline** → Name: "BookBazaar-Deploy"
2. In **Pipeline** section:
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: Your GitHub repo URL
   - **Script Path**: Jenkinsfile
3. **Save**

**✅ Jenkins is now configured!**

---

## 📊 Step 5: Monitoring Setup (Instance 2 Enhancement)

**Instance 2 now serves dual purpose: Team Member 2's Development + Monitoring Server**

### **5.1 Install Prometheus (on Instance 2 - alongside development environment)**

```bash
ssh -i team-key-mumbai.pem ubuntu@INSTANCE2_IP

echo "Setting up monitoring while preserving development environment..."

# Create prometheus user (separate from development user)
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

echo "✅ Instance 2 now runs: Development Environment + Prometheus Monitoring"
echo "✅ Team Member 2 can still develop while monitoring the entire team's infrastructure"
```

### **5.2 Configure Prometheus**

**Create `/etc/prometheus/prometheus.yml`:**
```bash
sudo nano /etc/prometheus/prometheus.yml
```

**Add this content:**
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
        - 'INSTANCE1_IP:9100'
        - 'INSTANCE2_IP:9100'
        - 'INSTANCE3_IP:9100'
```

**Replace INSTANCE_IPs with actual IPs**

### **5.3 Create Prometheus Service**

```bash
sudo nano /etc/systemd/system/prometheus.service
```

**Add:**
```ini
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
```

### **5.4 Start Prometheus**

```bash
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
sudo systemctl status prometheus
```

### **5.5 Install Node Exporter (on all instances)**

**Run this on each instance:**
```bash
# Download Node Exporter
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz
tar xvf node_exporter-1.4.0.linux-amd64.tar.gz

# Install Node Exporter
sudo cp node_exporter-1.4.0.linux-amd64/node_exporter /usr/local/bin
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
```

**Create service file:**
```bash
sudo nano /etc/systemd/system/node_exporter.service
```

**Add:**
```ini
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
```

**Start service:**
```bash
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
```

### **5.6 Install Grafana (on Instance 2)**

```bash
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
```

### **5.7 Configure Grafana**

1. **Access Grafana**: `http://INSTANCE2_IP:3000`
2. **Login**: admin/admin (change password when prompted)
3. **Add Data Source**:
   - Click **+** → **Data Sources**
   - Choose **Prometheus**
   - URL: `http://localhost:9090`
   - **Save & Test**
4. **Import Dashboard**:
   - Click **+** → **Import**
   - Dashboard ID: `1860`
   - **Load** → **Import**

**✅ Monitoring is now working!**

---

## 🔄 Step 6: Complete Workflow Testing

### **6.1 Test Each Component**

**Test Docker:**
```bash
# On any instance
docker run hello-world
```

**Test Ansible:**
```bash
# On Instance 1
ansible -i ~/ansible-setup/inventory/hosts.ini all -m ping
```

**Test Jenkins:**
- Open: `http://INSTANCE1_IP:8080`
- Should see Jenkins dashboard

**Test Monitoring:**
- Prometheus: `http://INSTANCE2_IP:9090`
- Grafana: `http://INSTANCE2_IP:3000`

### **6.2 Deploy Your Application**

**Create deployment playbook:**
```bash
# On Instance 1
cd ~/ansible-setup
nano playbooks/deploy-app.yml
```

**Add:**
```yaml
---
- name: Deploy Book Bazaar App
  hosts: web_servers
  become: yes
  
  tasks:
    - name: Pull latest code
      git:
        repo: "https://github.com/YOUR-USERNAME/YOUR-REPO.git"
        dest: "/opt/bookbazaar"
        
    - name: Build Docker image
      command: docker build -t bookbazaar /opt/bookbazaar
      
    - name: Run container
      command: docker run -d -p 3000:3000 --name bookbazaar bookbazaar
```

**Deploy:**
```bash
ansible-playbook -i inventory/hosts.ini playbooks/deploy-app.yml
```

**✅ Your application is now deployed!**

---

## 🎯 Step 7: Explanation for Professor

### **What Each Tool Does:**

**Docker:**
- "Packages our website with all its dependencies"
- "Ensures it runs the same on all servers"
- "Makes deployment simple and consistent"

**Ansible:**
- "Automates server configuration"
- "No more manual commands on each server"
- "Ensures all servers are configured identically"

**Jenkins:**
- "Automatically deploys when we push code to GitHub"
- "Runs tests before deployment"
- "Saves time and reduces human errors"

**Prometheus & Grafana:**
- "Monitors server performance and application health"
- "Shows real-time metrics and alerts"
- "Helps identify issues before they become problems"

### **Benefits Demonstrated:**

1. **Automation**: No manual deployments needed
2. **Consistency**: All servers configured the same way
3. **Monitoring**: Real-time visibility into system health
4. **Reliability**: Automated testing prevents bad deployments
5. **Scalability**: Easy to add more servers

---

## ⚠️ Troubleshooting Common Issues

### **Git Pull/Merge Issues:**
```bash
# Error: "untracked working tree files would be overwritten by merge"
# Solution 1: Remove the conflicting file
rm package-lock.json
git pull origin main

# Solution 2: Stash untracked files
git add package-lock.json
git stash
git pull origin main
git stash pop  # This will restore your local changes

# Solution 3: Force overwrite (careful - this will delete local changes)
git fetch origin
git reset --hard origin/main

# For your specific case, run this:
rm package-lock.json
git pull origin main
npm install  # This will regenerate package-lock.json
```

### **Git Divergent Branches Issues:**
```bash
# Error: "You have divergent branches and need to specify how to reconcile them"
# This happens when both local and remote have different commits

# Solution 1: Merge approach (recommended for team development)
git config pull.rebase false
git pull origin main
# This creates a merge commit combining both histories

# Solution 2: Rebase approach (cleaner history)
git config pull.rebase true
git pull origin main
# This replays your local commits on top of remote commits

# Solution 3: Fast-forward only (safest, but may fail)
git config pull.ff only
git pull origin main
# Only works if your branch can be fast-forwarded

# For your specific case (team development), use merge:
git config pull.rebase false
git pull origin main

# If you want to set this globally for all repositories:
git config --global pull.rebase false
```

### **Git Authentication Issues:**
```bash
# Error: "Password authentication is not supported for Git operations"
# GitHub requires Personal Access Token (PAT) instead of password

# Solution 1: Create and use Personal Access Token
# 1. Go to GitHub.com → Settings → Developer settings → Personal access tokens → Tokens (classic)
# 2. Click "Generate new token" → "Generate new token (classic)"
# 3. Give it a name like "DevOps Project Token"
# 4. Select scopes: repo, workflow, write:packages, delete:packages
# 5. Click "Generate token" 
# 6. COPY THE TOKEN IMMEDIATELY (you won't see it again!)

# Use the token as password when prompted:
git push origin feature/book-search
# Username: RA2211003010031
# Password: [PASTE YOUR PERSONAL ACCESS TOKEN HERE]

# Solution 2: Configure Git to store credentials
git config --global credential.helper store
git push origin feature/book-search
# Enter username and token once, it will be saved for future use

# Solution 3: Use SSH instead of HTTPS (recommended for development)
# 1. Generate SSH key
ssh-keygen -t ed25519 -C "your-email@example.com"
# 2. Add to SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
# 3. Copy public key to GitHub
cat ~/.ssh/id_ed25519.pub
# 4. Add to GitHub: Settings → SSH and GPG keys → New SSH key
# 5. Change remote URL
git remote set-url origin git@github.com:RA2211003010031/website-book-store.git
# 6. Test
git push origin feature/book-search
```

### **Git Merge Conflicts:**
```bash
# If merge conflicts occur during pull
git status  # See which files have conflicts

# Edit conflicted files manually, then:
git add .
git commit -m "Resolve merge conflicts"

# Or use a merge tool:
git mergetool
```

### **SSH Connection Issues:**
```bash
# Fix key permissions
chmod 400 team-key-mumbai.pem

# Test connection
ssh -i team-key-mumbai.pem ubuntu@INSTANCE_IP
```

### **Docker Permission Issues:**
```bash
# Add user to docker group
sudo usermod -aG docker ubuntu
# Logout and login again
```

### **Ansible Connectivity Issues:**
```bash
# Test with verbose output
ansible -i inventory/hosts.ini all -m ping -vvv
```

### **Jenkins Access Issues:**
```bash
# Check Jenkins status
sudo systemctl status jenkins

# Check port is open
netstat -tlnp | grep 8080
```

### **Monitoring Not Working:**
```bash
# Check services
sudo systemctl status prometheus
sudo systemctl status grafana-server

# Check if ports are accessible
curl http://localhost:9090
curl http://localhost:3000
```

---

## 📝 Summary Checklist

After completing this guide, you should have:

- ✅ Docker installed and working on all instances
- ✅ Ansible configured and able to manage all servers
- ✅ Jenkins running with CI/CD pipeline
- ✅ Prometheus collecting metrics from all servers
- ✅ Grafana showing beautiful dashboards
- ✅ Automated deployment process
- ✅ Monitoring and alerting system

---

## 🎯 Complete Implementation Summary

### **Phase 1 Achievement: Collaborative Development ✅**
- **Instance 1**: Team Member 1's development environment
- **Instance 2**: Team Member 2's development environment  
- **Instance 3**: Team Member 3's development environment
- **Git Workflow**: Feature branches, pull requests, code review
- **Remote Development**: No local machines needed
- **Collaborative Features**: Shared project, version control, team coordination

### **Phase 2 Achievement: DevOps Enhancement 🚀**
- **Instance 1**: Development + **Jenkins CI/CD** (automated deployments)
- **Instance 2**: Development + **Monitoring** (Prometheus/Grafana dashboards)
- **Instance 3**: Development + **Production** (Docker containerization)
- **Automation**: Ansible configuration management
- **Containerization**: Docker for consistent deployments
- **Monitoring**: Real-time metrics and alerts

### **Dual-Purpose Benefits:**
1. ✅ **Meets teacher's requirement** (3-instance team development)
2. ✅ **Shows advanced skills** (industry-standard DevOps tools)
3. ✅ **Demonstrates efficiency** (manual vs automated workflows)
4. ✅ **Real-world relevance** (how professional teams actually work)

### **Final Access Points:**
- **Development Work**: SSH to any instance and code normally
- **Jenkins Dashboard**: `http://INSTANCE1_IP:8080` (automated deployments)
- **Prometheus Metrics**: `http://INSTANCE2_IP:9090` (system monitoring)
- **Grafana Dashboards**: `http://INSTANCE2_IP:3000` (visual metrics)
- **Production App**: `http://INSTANCE3_IP:3000` (deployed application)

## 🎓 **Presentation Strategy:**

### **First 15 Minutes: Show Collaborative Development**
1. **Demonstrate team workflow** on all 3 instances
2. **Show Git collaboration** (different team members, feature branches)
3. **Explain remote development** (no local setup needed)
4. **Highlight problem solved** (team coordination in different locations)

### **Next 15 Minutes: Show DevOps Enhancement**  
1. **Demonstrate automated deployment** (Jenkins pipeline)
2. **Show monitoring dashboards** (Grafana visualizations)
3. **Explain efficiency gains** (manual vs automated)
4. **Highlight industry relevance** (modern software development)

### **Last 5 Minutes: Explain Benefits**
1. **Time savings** through automation
2. **Reliability** through testing and monitoring  
3. **Scalability** through containerization
4. **Professional practices** used in industry

## 🏆 **Why This Approach Gets Maximum Points:**

1. **Exceeds Requirements**: Goes beyond basic 3-instance setup
2. **Shows Understanding**: Demonstrates both collaboration and automation
3. **Industry Relevant**: Uses real-world tools and practices
4. **Well Documented**: Clear explanation of every step
5. **Practical Demo**: Working system that can be tested live

**🎉 Perfect combination of meeting requirements + showing advanced skills!**
