#!/bin/bash

# Unified DevOps Setup Script for Online Book Bazaar
# This script installs Docker, Node.js, Jenkins, Prometheus, and Grafana

echo "🚀 Starting Unified DevOps Setup for Online Book Bazaar"
echo "======================================================="

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install common packages
echo "🔧 Installing common packages..."
sudo apt install -y curl wget unzip git htop vim jq software-properties-common apt-transport-https ca-certificates

# Install Docker
echo "🐳 Installing Docker..."
sudo apt install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Install Node.js
echo "📟 Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install Java 11 (required for Jenkins)
echo "☕ Installing Java 11..."
sudo apt install -y openjdk-11-jdk

# Install Jenkins
echo "🏗️ Installing Jenkins..."
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Prometheus
echo "📊 Installing Prometheus..."
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Download and install Prometheus
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
tar xvf prometheus-2.45.0.linux-amd64.tar.gz
sudo cp prometheus-2.45.0.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.45.0.linux-amd64/promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool

# Install Grafana
echo "📈 Installing Grafana..."
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt update
sudo apt install -y grafana

# Start Grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Install Node Exporter
echo "📈 Installing Node Exporter..."
sudo useradd --no-create-home --shell /bin/false node_exporter
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.0/node_exporter-1.6.0.linux-amd64.tar.gz
tar xvf node_exporter-1.6.0.linux-amd64.tar.gz
sudo cp node_exporter-1.6.0.linux-amd64/node_exporter /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Create systemd service for Node Exporter
sudo tee /etc/systemd/system/node_exporter.service > /dev/null << 'EOF'
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
EOF

# Start Node Exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

echo ""
echo "✅ Installation completed!"
echo "========================"
echo ""
echo "🌐 Service URLs:"
echo "• Jenkins: http://$(curl -s ifconfig.me):8080"
echo "• Prometheus: http://$(curl -s ifconfig.me):9090"
echo "• Grafana: http://$(curl -s ifconfig.me):3000"
echo "• Node Exporter: http://$(curl -s ifconfig.me):9100"
echo ""
echo "🔑 Initial Passwords:"
echo "• Jenkins: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo 'Not available yet')"
echo "• Grafana: admin/admin (change on first login)"
echo ""
echo "📋 Next Steps:"
echo "1. Configure Jenkins with plugins and create pipelines"
echo "2. Configure Prometheus targets"
echo "3. Import Grafana dashboards"
echo "4. Set up monitoring alerts"
echo ""
echo "🎉 DevOps infrastructure is ready!"
