#!/bin/bash

# Fix Issues Script for Online Book Bazaar DevOps Setup
# This script addresses the issues found during the initial setup

set -e

INSTANCE1_IP="${1:-13.201.70.160}"
INSTANCE2_IP="${2:-13.232.108.169}"
INSTANCE3_IP="${3:-3.111.215.37}"
KEY_FILE="team-key-mumbai.pem"

echo "=== 🔧 Fixing DevOps Setup Issues ==="
echo "Instance 1 (App): $INSTANCE1_IP"
echo "Instance 2 (Jenkins): $INSTANCE2_IP"
echo "Instance 3 (Monitoring): $INSTANCE3_IP"

# Function to wait for SSH connectivity
wait_for_ssh() {
    local ip=$1
    echo "Waiting for SSH connectivity to $ip..."
    while ! ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i "$KEY_FILE" ubuntu@"$ip" echo "SSH Ready" &>/dev/null; do
        sleep 2
    done
    echo "SSH connectivity to $ip established!"
}

# Function to fix Jenkins installation
fix_jenkins() {
    local jenkins_ip=$1
    echo "🔧 Fixing Jenkins installation on $jenkins_ip..."
    
    ssh -o StrictHostKeyChecking=no -i "$KEY_FILE" ubuntu@"$jenkins_ip" << 'EOF'
        # Remove any partial Jenkins installation
        sudo apt-get remove -y jenkins || true
        sudo rm -rf /var/lib/jenkins || true
        sudo rm -rf /etc/default/jenkins || true
        
        # Fix Jenkins GPG key issue
        echo "Adding Jenkins GPG key..."
        wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo apt-key add -
        
        # Add Jenkins repository properly
        echo "deb https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
        
        # Update package list
        sudo apt-get update
        
        # Install Jenkins
        echo "Installing Jenkins..."
        sudo apt-get install -y jenkins
        
        # Start and enable Jenkins
        sudo systemctl start jenkins
        sudo systemctl enable jenkins
        
        # Wait for Jenkins to initialize
        echo "Waiting for Jenkins to initialize..."
        sleep 30
        
        # Check Jenkins status
        sudo systemctl status jenkins --no-pager
        
        # Get initial admin password
        echo "=== Jenkins Initial Admin Password ==="
        sudo cat /var/lib/jenkins/secrets/initialAdminPassword || echo "Password file not ready yet"
        echo "======================================="
EOF
    
    echo "✅ Jenkins fix completed on $jenkins_ip"
}

# Function to deploy Book Bazaar app properly
fix_book_bazaar_app() {
    local app_ip=$1
    echo "🔧 Fixing Book Bazaar application on $app_ip..."
    
    ssh -o StrictHostKeyChecking=no -i "$KEY_FILE" ubuntu@"$app_ip" << 'EOF'
        # Create a simple Book Bazaar application
        echo "Creating Book Bazaar application..."
        mkdir -p /home/ubuntu/book-bazaar-app
        cd /home/ubuntu/book-bazaar-app
        
        # Create package.json
        cat > package.json << 'PKG_EOF'
{
  "name": "online-book-bazaar",
  "version": "1.0.0",
  "description": "Online Book Bazaar - A modern e-commerce platform for books",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.0.3"
  },
  "keywords": ["books", "ecommerce", "nodejs", "express"],
  "author": "DevOps Team",
  "license": "MIT"
}
PKG_EOF

        # Create main server file
        cat > server.js << 'SERVER_EOF'
const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 8000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Sample book data
const books = [
    { id: 1, title: "The DevOps Handbook", author: "Gene Kim", price: 29.99, category: "Technology" },
    { id: 2, title: "Clean Code", author: "Robert Martin", price: 35.99, category: "Programming" },
    { id: 3, title: "Kubernetes in Action", author: "Marko Lukša", price: 45.99, category: "Cloud" },
    { id: 4, title: "Site Reliability Engineering", author: "Google", price: 39.99, category: "SRE" },
    { id: 5, title: "Docker Deep Dive", author: "Nigel Poulton", price: 32.99, category: "Containers" }
];

// Routes
app.get('/', (req, res) => {
    res.json({
        message: "Welcome to Online Book Bazaar! 📚",
        status: "running",
        timestamp: new Date().toISOString(),
        endpoints: [
            "GET /books - Get all books",
            "GET /books/:id - Get book by ID",
            "GET /health - Health check"
        ]
    });
});

app.get('/books', (req, res) => {
    res.json({
        success: true,
        data: books,
        total: books.length
    });
});

app.get('/books/:id', (req, res) => {
    const book = books.find(b => b.id === parseInt(req.params.id));
    if (book) {
        res.json({ success: true, data: book });
    } else {
        res.status(404).json({ success: false, message: "Book not found" });
    }
});

app.get('/health', (req, res) => {
    res.json({
        status: "healthy",
        uptime: process.uptime(),
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development'
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Online Book Bazaar server running on port ${PORT}`);
    console.log(`📖 Visit http://localhost:${PORT} to see the API`);
});
SERVER_EOF

        # Create Dockerfile
        cat > Dockerfile << 'DOCKER_EOF'
FROM node:16-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Start the application
CMD ["npm", "start"]
DOCKER_EOF

        # Create .dockerignore
        cat > .dockerignore << 'IGNORE_EOF'
node_modules
npm-debug.log
.git
.gitignore
README.md
Dockerfile
.dockerignore
IGNORE_EOF

        # Build and run the application
        echo "Building Docker image..."
        sudo docker build -t book-bazaar:latest .
        
        # Stop any existing container
        sudo docker stop book-bazaar-app || true
        sudo docker rm book-bazaar-app || true
        
        # Run the application
        echo "Starting Book Bazaar application..."
        sudo docker run -d \
            --name book-bazaar-app \
            --restart unless-stopped \
            -p 8000:8000 \
            book-bazaar:latest
        
        # Verify the application is running
        sleep 10
        echo "=== Application Status ==="
        sudo docker ps | grep book-bazaar || echo "Container not running"
        curl -s http://localhost:8000/health | head -10 || echo "App not responding yet"
        echo "=========================="
EOF
    
    echo "✅ Book Bazaar application fix completed on $app_ip"
}

# Function to setup monitoring stack
setup_monitoring() {
    local monitoring_ip=$1
    echo "📊 Setting up monitoring stack on $monitoring_ip..."
    
    ssh -o StrictHostKeyChecking=no -i "$KEY_FILE" ubuntu@"$monitoring_ip" << 'EOF'
        # Install Docker (if not already installed)
        if ! command -v docker &> /dev/null; then
            echo "Installing Docker..."
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            sudo usermod -aG docker ubuntu
        fi
        
        # Create monitoring directory
        mkdir -p /home/ubuntu/monitoring
        cd /home/ubuntu/monitoring
        
        # Create Prometheus configuration
        cat > prometheus.yml << 'PROM_EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets: []

rule_files: []

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'book-bazaar-app'
    static_configs:
      - targets: ['REPLACE_APP_IP:8000']
    metrics_path: '/health'
    scrape_interval: 30s
  
  - job_name: 'jenkins'
    static_configs:
      - targets: ['REPLACE_JENKINS_IP:8080']
    scrape_interval: 60s
PROM_EOF

        # Create docker-compose.yml for monitoring stack
        cat > docker-compose.yml << 'COMPOSE_EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_SECURITY_ADMIN_USER=admin
    volumes:
      - grafana_data:/var/lib/grafana
    restart: unless-stopped

volumes:
  prometheus_data:
  grafana_data:
COMPOSE_EOF

        # Install docker-compose if not present
        if ! command -v docker-compose &> /dev/null; then
            echo "Installing docker-compose..."
            sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
        fi
        
        # Start monitoring stack
        echo "Starting monitoring stack..."
        sudo docker-compose up -d
        
        # Wait for services to start
        sleep 20
        
        # Check status
        echo "=== Monitoring Stack Status ==="
        sudo docker-compose ps
        echo "==============================="
EOF
    
    echo "✅ Monitoring stack setup completed on $monitoring_ip"
}

# Main execution
echo "🔧 Starting issue fixes..."

# Wait for all instances to be ready
for ip in "$INSTANCE1_IP" "$INSTANCE2_IP" "$INSTANCE3_IP"; do
    wait_for_ssh "$ip"
done

echo "✅ All instances are ready!"

# Fix issues in parallel for faster execution
echo "🚀 Running fixes..."

# Fix Jenkins installation
fix_jenkins "$INSTANCE2_IP" &

# Fix Book Bazaar application  
fix_book_bazaar_app "$INSTANCE1_IP" &

# Setup monitoring stack
setup_monitoring "$INSTANCE3_IP" &

# Wait for all fixes to complete
wait

echo ""
echo "🎉 All fixes completed!"
echo ""
echo "=== 📋 Service URLs ==="
echo "📚 Book Bazaar App:    http://$INSTANCE1_IP:8000"
echo "🔧 Jenkins:           http://$INSTANCE2_IP:8080"
echo "📊 Prometheus:        http://$INSTANCE3_IP:9090"
echo "📈 Grafana:           http://$INSTANCE3_IP:3000 (admin/admin)"
echo "======================"
echo ""
echo "🔍 Run './check-status.sh' to verify all services are working!"
