#!/bin/bash

# Update system
apt-get update -y

# Install essential packages for development
apt-get install -y curl wget git nginx vim nano htop tree unzip software-properties-common

# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs

# Install Python and pip
apt-get install -y python3 python3-pip python3-venv

# Install development tools
npm install -g pm2 nodemon live-server
pip3 install virtualenv

# Install VS Code Server (code-server) for web-based development
curl -fsSL https://code-server.dev/install.sh | sh

# Install Docker for containerized development
apt-get install -y apt-transport-https ca-certificates gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io
usermod -aG docker ubuntu

# Create development workspace
mkdir -p /home/ubuntu/workspace
cd /home/ubuntu/workspace

# Clone the repository for development
git clone ${github_repo} book-bazaar
cd book-bazaar

# Set up git configuration (team members will need to configure their own)
git config --global init.defaultBranch main

# Install project dependencies if they exist
if [ -f "package.json" ]; then
    npm install
elif [ -f "requirements.txt" ]; then
    pip3 install -r requirements.txt
fi

# Create development environment file
cat > .env << EOF
NODE_ENV=development
PORT=3000
DEBUG=true
EOF

# Set up code-server (VS Code in browser)
mkdir -p /home/ubuntu/.config/code-server
cat > /home/ubuntu/.config/code-server/config.yaml << EOF
bind-addr: 0.0.0.0:8080
auth: password
password: bookbazaar2024
cert: false
EOF

# Start code-server as a service
systemctl enable --now code-server@ubuntu

# Set proper ownership
chown -R ubuntu:ubuntu /home/ubuntu/workspace
chown -R ubuntu:ubuntu /home/ubuntu/.config

# Set proper ownership
chown -R ubuntu:ubuntu /home/ubuntu/workspace
chown -R ubuntu:ubuntu /home/ubuntu/.config

# Create a simple nginx configuration for development
cat > /etc/nginx/sites-available/dev-portal << EOF
server {
    listen 80;
    server_name _;

    # Code server (VS Code in browser)
    location /code/ {
        proxy_pass http://localhost:8080/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    # Development server (when running)
    location /app/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    # Default page with development info
    location / {
        root /var/www/html;
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

# Create a development info page
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Book Bazaar Development Environment</title>
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
        <h1>🚀 Book Bazaar Development Environment</h1>
        <p>Welcome to your development instance! Choose how you want to work on the project:</p>
        
        <div class="option">
            <h3>🌐 Option 1: VS Code in Browser</h3>
            <p>Access a full VS Code editor directly in your browser:</p>
            <p><a href="/code/" target="_blank">Open VS Code Editor</a></p>
            <div class="code">Password: bookbazaar2024</div>
        </div>

        <div class="option">
            <h3>💻 Option 2: SSH Access</h3>
            <p>Connect via SSH for terminal-based development:</p>
            <div class="code">ssh -i team-key-mumbai.pem ubuntu@$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)</div>
            <p>Project location: <code>/home/ubuntu/workspace/book-bazaar/</code></p>
        </div>

        <div class="option">
            <h3>🔧 Option 3: Run Development Server</h3>
            <p>After making changes, test your application:</p>
            <p><a href="/app/" target="_blank">View Your App</a> (when dev server is running)</p>
        </div>

        <div class="note">
            <strong>📝 Development Workflow:</strong><br>
            1. Use VS Code in browser or SSH to edit code<br>
            2. Make your changes in <code>/home/ubuntu/workspace/book-bazaar/</code><br>
            3. Test your changes by running the development server<br>
            4. Commit and push your changes when ready
        </div>

        <div class="note">
            <strong>🔗 Quick Commands (via SSH):</strong><br>
            • <code>cd /home/ubuntu/workspace/book-bazaar</code> - Go to project directory<br>
            • <code>npm run dev</code> or <code>npm start</code> - Start development server<br>
            • <code>git status</code> - Check git status<br>
            • <code>git pull</code> - Pull latest changes<br>
            • <code>git add . && git commit -m "message" && git push</code> - Commit changes
        </div>
    </div>
</body>
</html>
EOF

# Enable the site
ln -s /etc/nginx/sites-available/dev-portal /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test and reload nginx
nginx -t && systemctl restart nginx

# Enable services to start on boot
systemctl enable nginx
systemctl enable code-server@ubuntu

# Log completion
echo "Book Bazaar development environment setup completed at $(date)" >> /var/log/book-bazaar-setup.log
echo "VS Code server running on port 8080" >> /var/log/book-bazaar-setup.log
echo "Project cloned to /home/ubuntu/workspace/book-bazaar" >> /var/log/book-bazaar-setup.log
