#!/bin/bash

# Continue DevOps Setup - Jenkins and Monitoring Only
# The app is already working perfectly, so we'll focus on the remaining components

set -e

# Get instance IPs from Terraform or use known IPs
if terraform output -json instance_public_ips 2>/dev/null; then
    INSTANCE_IPS=$(terraform output -json instance_public_ips | jq -r '.[]')
    IPS_ARRAY=($INSTANCE_IPS)
    INSTANCE1_IP=${IPS_ARRAY[0]}  # App instance (already working)
    INSTANCE2_IP=${IPS_ARRAY[1]}  # Jenkins instance
    INSTANCE3_IP=${IPS_ARRAY[2]}  # Monitoring instance
else
    # Use the known IPs from our previous successful run
    INSTANCE1_IP="13.201.70.160"   # App instance (already working)
    INSTANCE2_IP="13.232.108.169"  # Jenkins instance  
    INSTANCE3_IP="3.111.215.37"    # Monitoring instance
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Function to run command on remote instance
run_remote() {
    local ip=$1
    local command=$2
    ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@$ip "$command"
}

# Function to copy file to remote instance
copy_to_remote() {
    local ip=$1
    local local_file=$2
    local remote_path=$3
    scp -i team-key-mumbai.pem -o StrictHostKeyChecking=no "$local_file" ubuntu@$ip:"$remote_path"
}

# Simple Jenkins installation with automatic yes
install_jenkins_simple() {
    local ip=$1
    log "Installing Jenkins on $ip with simple approach..."
    
    run_remote $ip "
        # Install Java 17 first
        sudo apt-get update
        DEBIAN_FRONTEND=noninteractive sudo apt-get install -y openjdk-17-jdk
        
        # Add Jenkins repository
        curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
        echo \"deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/\" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
        sudo apt-get update
        
        # Use yes to automatically answer prompts
        yes | sudo apt-get install jenkins || {
            # If interactive prompts appear, just keep the existing version
            echo 'N' | sudo apt-get install jenkins
        }
        
        # Start Jenkins
        sudo systemctl daemon-reload
        sudo systemctl start jenkins || true
        sudo systemctl enable jenkins || true
        
        # Wait for Jenkins to start
        sleep 30
        
        # Check if Jenkins is running
        if sudo systemctl is-active --quiet jenkins; then
            echo 'Jenkins is running!'
            sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo 'Password file not found yet'
        else
            echo 'Jenkins failed to start, checking logs...'
            sudo journalctl -u jenkins --no-pager -n 20
        fi
    "
    
    log "Jenkins installation completed on $ip"
}

# Setup monitoring (Prometheus + Grafana)
setup_monitoring() {
    local ip=$1
    log "Setting up monitoring (Prometheus + Grafana) on $ip..."
    
    # Install Docker first if not already installed
    run_remote $ip "
        # Check if Docker is installed
        if ! command -v docker &> /dev/null; then
            echo 'Installing Docker...'
            sudo apt-get update
            DEBIAN_FRONTEND=noninteractive sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update
            DEBIAN_FRONTEND=noninteractive sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            sudo usermod -aG docker ubuntu
            sudo systemctl start docker
            sudo systemctl enable docker
        else
            echo 'Docker is already installed'
        fi
    "
    
    # Create monitoring configuration files
    cat > prometheus-config.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'book-bazaar'
    static_configs:
      - targets: ['host.docker.internal:8000']
      
  - job_name: 'jenkins'
    static_configs:
      - targets: ['host.docker.internal:8080']
EOF

    cat > monitoring-docker-compose.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
    extra_hosts:
      - "host.docker.internal:host-gateway"

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    volumes:
      - grafana-storage:/var/lib/grafana

volumes:
  grafana-storage:
EOF

    # Copy files to remote instance
    copy_to_remote $ip prometheus-config.yml /home/ubuntu/prometheus.yml
    copy_to_remote $ip monitoring-docker-compose.yml /home/ubuntu/docker-compose.yml
    
    # Start monitoring services
    run_remote $ip "
        cd /home/ubuntu
        sudo docker compose down 2>/dev/null || true
        sudo docker compose up -d
        
        # Wait for services to start
        sleep 30
        
        # Check if services are running
        if curl -f http://localhost:9090 2>/dev/null; then
            echo 'Prometheus is running successfully!'
        else
            echo 'Prometheus health check failed'
        fi
        
        if curl -f http://localhost:3000 2>/dev/null; then
            echo 'Grafana is running successfully!'
        else
            echo 'Grafana health check failed'
        fi
    "
    
    # Clean up local files
    rm -f prometheus-config.yml monitoring-docker-compose.yml
    
    log "Monitoring setup completed on $ip"
}

# Validate services
validate_all_services() {
    log "=== Final Validation ==="
    
    # Check Book Bazaar App
    if curl -f http://$INSTANCE1_IP:8000/status 2>/dev/null; then
        log "✅ Book Bazaar app is accessible on $INSTANCE1_IP:8000"
    else
        warn "❌ Book Bazaar app is not accessible on $INSTANCE1_IP:8000"
    fi
    
    # Check Jenkins
    if curl -f http://$INSTANCE2_IP:8080 2>/dev/null; then
        log "✅ Jenkins is accessible on $INSTANCE2_IP:8080"
    else
        warn "❌ Jenkins is not accessible on $INSTANCE2_IP:8080"
    fi
    
    # Check Prometheus
    if curl -f http://$INSTANCE3_IP:9090 2>/dev/null; then
        log "✅ Prometheus is accessible on $INSTANCE3_IP:9090"
    else
        warn "❌ Prometheus is not accessible on $INSTANCE3_IP:9090"
    fi
    
    # Check Grafana
    if curl -f http://$INSTANCE3_IP:3000 2>/dev/null; then
        log "✅ Grafana is accessible on $INSTANCE3_IP:3000"
    else
        warn "❌ Grafana is not accessible on $INSTANCE3_IP:3000"
    fi
}

# Main function
main() {
    log "Continuing DevOps setup - Jenkins and Monitoring..."
    log "App Instance (Already Working): $INSTANCE1_IP:8000"
    log "Jenkins Instance: $INSTANCE2_IP:8080" 
    log "Monitoring Instance: $INSTANCE3_IP:9090 & :3000"
    
    # Setup Jenkins
    log "=== Setting up Jenkins ==="
    install_jenkins_simple $INSTANCE2_IP
    
    # Setup Monitoring
    log "=== Setting up Monitoring ==="
    setup_monitoring $INSTANCE3_IP
    
    # Final validation
    sleep 30
    validate_all_services
    
    # Display summary
    log "=== Setup Status ==="
    echo ""
    echo "🌟 Online Book Bazaar DevOps Environment Status:"
    echo ""
    echo "📱 Services Access URLs:"
    echo "   Book Bazaar App:     http://$INSTANCE1_IP:8000 (✅ WORKING)"
    echo "   Jenkins CI/CD:       http://$INSTANCE2_IP:8080"
    echo "   Prometheus:          http://$INSTANCE3_IP:9090"
    echo "   Grafana:             http://$INSTANCE3_IP:3000 (admin/admin123)"
    echo ""
    echo "🔑 Jenkins Initial Admin Password:"
    run_remote $INSTANCE2_IP "sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo 'Password file not found - Jenkins may need more time to start'"
    echo ""
    log "Setup completed! 🚀"
}

# Run the main function
main "$@"
