# 🚨 DevOps Demo Troubleshooting Guide

## Quick Fixes for Common Issues During Video Recording

### 🔧 Service Not Starting

**Jenkins Issues:**
```bash
# Check status
sudo systemctl status jenkins

# Restart Jenkins
sudo systemctl restart jenkins

# Check logs
sudo journalctl -u jenkins -f

# If port 8080 not accessible
sudo ufw allow 8080
```

**Docker Issues:**
```bash
# Restart Docker
sudo systemctl restart docker

# Check Docker status
docker --version
docker ps

# If permission denied
sudo usermod -aG docker ubuntu
newgrp docker
```

**Application Not Loading:**
```bash
# Check if container is running
docker ps

# Check application logs
docker logs [container-name]

# Restart application container
docker restart [container-name]

# If port 3000 not accessible
sudo ufw allow 3000
```

### 📊 Monitoring Issues

**Prometheus Not Accessible:**
```bash
# Check Prometheus status
sudo systemctl status prometheus

# Restart Prometheus
sudo systemctl restart prometheus

# Check configuration
sudo cat /etc/prometheus/prometheus.yml

# Check if port 9090 is open
sudo ufw allow 9090
```

**Grafana Problems:**
```bash
# Check Grafana status
sudo systemctl status grafana-server

# Restart Grafana
sudo systemctl restart grafana-server

# Reset admin password
sudo grafana-cli admin reset-admin-password admin

# Check if port 3000 is open for Grafana
sudo ufw allow 3000
```

### 🔄 Ansible Issues

**Connection Problems:**
```bash
# Test connectivity
ansible -i inventory/hosts.ini all -m ping

# Check SSH key permissions
chmod 400 ~/team-key-mumbai.pem

# Test manual SSH
ssh -i ~/team-key-mumbai.pem ubuntu@[instance-ip]
```

**Playbook Failures:**
```bash
# Run with verbose output
ansible-playbook -i inventory/hosts.ini playbooks/deploy-app.yml -vvv

# Check individual tasks
ansible -i inventory/hosts.ini all -m setup
```

### 🌐 Network Connectivity

**Can't Access Web Interfaces:**
1. **Check AWS Security Groups:**
   - Port 22 (SSH): Your IP
   - Port 80 (HTTP): 0.0.0.0/0
   - Port 3000 (App): 0.0.0.0/0
   - Port 8080 (Jenkins): 0.0.0.0/0
   - Port 9090 (Prometheus): 0.0.0.0/0

2. **Check UFW Firewall:**
```bash
sudo ufw status
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 3000
sudo ufw allow 8080
sudo ufw allow 9090
```

### 🔄 Jenkins Setup Issues

**Initial Setup Problems:**
```bash
# Get initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# If file doesn't exist, restart Jenkins
sudo systemctl restart jenkins
sleep 30
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

**Pipeline Creation:**
1. New Item → Pipeline
2. Pipeline script from SCM
3. Git repository URL
4. Credentials: none (public repo)
5. Branch: */main
6. Script Path: Jenkinsfile

### 🐳 Docker Troubleshooting

**Container Won't Start:**
```bash
# Check Docker daemon
sudo systemctl status docker

# Check available space
df -h

# Remove old containers/images
docker system prune -a

# Build image again
cd ~/projects/online-book-bazaar
docker build -t online-book-bazaar .
```

**Port Conflicts:**
```bash
# Check what's using port
sudo netstat -tulpn | grep :3000

# Kill process if needed
sudo kill -9 [PID]

# Use different port
docker run -d -p 3001:3000 --name book-app online-book-bazaar
```

### 🔍 Quick Health Check Commands

**Overall System Status:**
```bash
# Check all services
sudo systemctl status jenkins prometheus grafana-server node_exporter docker

# Check running containers
docker ps

# Check disk space
df -h

# Check memory
free -h

# Check network
ss -tulpn
```

**Application Verification:**
```bash
# Test application endpoints
curl http://localhost:3000
curl http://localhost:8080
curl http://localhost:9090
curl http://localhost:3000  # Grafana

# Check from external
curl http://[instance-ip]:3000
```

### 📝 Demo Recovery Steps

**If Demo Goes Wrong:**
1. **Take a deep breath** - stay calm
2. **Use these commands** to quickly diagnose
3. **Explain the issue** - shows real-world scenarios
4. **Fix it live** - demonstrates troubleshooting skills
5. **Continue confidently** - shows professionalism

### 🚀 Emergency Reset

**Complete Service Restart:**
```bash
# Stop all services
sudo systemctl stop jenkins prometheus grafana-server node_exporter
docker stop $(docker ps -q)

# Start all services
sudo systemctl start docker
sudo systemctl start jenkins
sudo systemctl start prometheus  
sudo systemctl start grafana-server
sudo systemctl start node_exporter

# Restart application containers
cd ~/projects/online-book-bazaar
docker-compose up -d
```

**Quick Verification:**
```bash
# Wait 2 minutes, then check
sleep 120
curl http://localhost:3000  # App
curl http://localhost:8080  # Jenkins
curl http://localhost:9090  # Prometheus
```

### 💡 Pro Tips for Demo

1. **Have backup plans** - Know these commands by heart
2. **Practice transitions** - Smooth movement between tools
3. **Explain while fixing** - Turn problems into learning moments
4. **Keep confidence** - Small hiccups show real-world experience
5. **Have URLs bookmarked** - Quick navigation during demo

### 🆘 Last Resort

If everything fails during recording:
1. **Stop recording**
2. **Run the automated script again**
3. **Wait for completion**
4. **Restart recording**
5. **Mention this shows automation reliability**

---

**Remember: A perfect demo is impressive, but handling issues gracefully is even more impressive!** 🏆
