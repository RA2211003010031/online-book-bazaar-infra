#!/bin/bash

# Script to update existing EC2 instances with development environment
# Run this if your instances were created with the old configuration

echo "🔧 Updating Existing Instances to Development Environment"
echo "========================================================"

KEY_FILE="team-key-mumbai.pem"
GITHUB_REPO="${1:-https://github.com/RA2211003010031/online-book-bazaar.git}"

# Check if key file exists
if [ ! -f "$KEY_FILE" ]; then
    echo "❌ Error: Key file '$KEY_FILE' not found."
    exit 1
fi

chmod 400 "$KEY_FILE"

echo "📋 Enter your instance IP addresses:"
read -p "Instance 1 IP: " IP1
read -p "Instance 2 IP: " IP2
read -p "Instance 3 IP: " IP3

# Function to update a single instance
update_instance() {
    local ip=$1
    local instance_num=$2
    
    echo ""
    echo "🔄 Updating Instance $instance_num ($ip)..."
    
    ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ubuntu@$ip << EOF
        set -e
        
        echo "📦 Installing development tools..."
        sudo apt-get update -y
        
        # Install development packages
        sudo apt-get install -y vim nano htop tree unzip software-properties-common
        
        # Install VS Code Server
        echo "💻 Installing VS Code Server..."
        curl -fsSL https://code-server.dev/install.sh | sudo sh
        
        # Install Docker
        echo "🐳 Installing Docker..."
        sudo apt-get install -y apt-transport-https ca-certificates gnupg lsb-release
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update -y
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
        sudo usermod -aG docker ubuntu
        
        # Install additional Node.js tools
        sudo npm install -g nodemon live-server
        
        # Create development workspace
        echo "📁 Setting up development workspace..."
        mkdir -p /home/ubuntu/workspace
        cd /home/ubuntu/workspace
        
        # Clone or update repository
        if [ -d "book-bazaar" ]; then
            echo "📥 Updating existing repository..."
            cd book-bazaar
            git pull
        else
            echo "📥 Cloning repository..."
            git clone $GITHUB_REPO book-bazaar
            cd book-bazaar
        fi
        
        # Install dependencies
        if [ -f "package.json" ]; then
            npm install
        fi
        
        # Set up VS Code Server
        echo "⚙️ Configuring VS Code Server..."
        mkdir -p /home/ubuntu/.config/code-server
        cat > /home/ubuntu/.config/code-server/config.yaml << EOL
bind-addr: 0.0.0.0:8080
auth: password
password: bookbazaar2024
cert: false
EOL
        
        # Start and enable code-server
        sudo systemctl enable --now code-server@ubuntu
        
        # Update nginx configuration
        echo "🌐 Updating nginx configuration..."
        sudo tee /etc/nginx/sites-available/dev-portal > /dev/null << EOL
server {
    listen 80;
    server_name _;

    # Code server (VS Code in browser)
    location /code/ {
        proxy_pass http://localhost:8080/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \\\$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \\\$host;
        proxy_set_header X-Real-IP \\\$remote_addr;
        proxy_set_header X-Forwarded-For \\\$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \\\$scheme;
        proxy_cache_bypass \\\$http_upgrade;
    }

    # Development server
    location /app/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \\\$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \\\$host;
        proxy_cache_bypass \\\$http_upgrade;
    }

    # Default page
    location / {
        root /var/www/html;
        try_files \\\$uri \\\$uri/ /index.html;
    }
}
EOL

        # Create development info page
        sudo tee /var/www/html/index.html > /dev/null << EOL
<!DOCTYPE html>
<html>
<head>
    <title>Book Bazaar Development - Instance $instance_num</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; }
        .option { background: #e8f4f8; padding: 15px; margin: 15px 0; border-radius: 5px; }
        .option h3 { margin-top: 0; color: #2c5f77; }
        a { color: #1e88e5; text-decoration: none; }
        a:hover { text-decoration: underline; }
        .code { background: #f0f0f0; padding: 10px; border-radius: 5px; font-family: monospace; margin: 10px 0; }
        .note { background: #fff3cd; border-left: 4px solid #ffc107; padding: 10px; margin: 15px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Book Bazaar Development - Instance $instance_num</h1>
        <p>Welcome to your development environment!</p>
        
        <div class="option">
            <h3>🌐 VS Code in Browser</h3>
            <p><a href="/code/" target="_blank">Open VS Code Editor</a></p>
            <div class="code">Password: bookbazaar2024</div>
        </div>

        <div class="option">
            <h3>🔧 Development Server</h3>
            <p><a href="/app/" target="_blank">View Your App</a> (when dev server is running)</p>
        </div>

        <div class="note">
            <strong>📁 Project Location:</strong> /home/ubuntu/workspace/book-bazaar/
        </div>
    </div>
</body>
</html>
EOL

        # Enable the site
        sudo ln -sf /etc/nginx/sites-available/dev-portal /etc/nginx/sites-enabled/
        sudo rm -f /etc/nginx/sites-enabled/default
        
        # Test and reload nginx
        sudo nginx -t && sudo systemctl reload nginx
        
        # Set proper ownership
        sudo chown -R ubuntu:ubuntu /home/ubuntu/workspace
        sudo chown -R ubuntu:ubuntu /home/ubuntu/.config
        
        echo "✅ Instance $instance_num setup completed!"
        echo "🌐 Access VS Code at: http://$ip/code/"
        echo "💻 SSH: ssh -i $KEY_FILE ubuntu@$ip"
EOF

    if [ $? -eq 0 ]; then
        echo "✅ Successfully updated Instance $instance_num ($ip)"
    else
        echo "❌ Failed to update Instance $instance_num ($ip)"
    fi
}

# Update all instances
if [ ! -z "$IP1" ]; then
    update_instance "$IP1" "1"
fi

if [ ! -z "$IP2" ]; then
    update_instance "$IP2" "2"
fi

if [ ! -z "$IP3" ]; then
    update_instance "$IP3" "3"
fi

echo ""
echo "🎉 Update process completed!"
echo ""
echo "🔗 Access your development environments:"
for i in 1 2 3; do
    eval IP=\$IP$i
    if [ ! -z "$IP" ]; then
        echo "Instance $i: http://$IP/code/ (VS Code) | ssh -i $KEY_FILE ubuntu@$IP"
    fi
done
