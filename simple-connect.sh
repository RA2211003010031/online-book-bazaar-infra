#!/bin/bash

# Simple SSH connection script for Online Book Bazaar development
echo "🚀 Online Book Bazaar - Simple Instance Access"
echo "=============================================="

KEY_FILE="team-key-mumbai.pem"

# Check if key file exists
if [ ! -f "$KEY_FILE" ]; then
    echo "❌ Error: Key file '$KEY_FILE' not found."
    echo "Make sure the key file is in the current directory."
    exit 1
fi

chmod 400 "$KEY_FILE"

echo ""
echo "📋 Enter your instance IP addresses (get them from AWS Console → EC2 → Instances):"
read -p "Instance 1 IP: " IP1
read -p "Instance 2 IP: " IP2  
read -p "Instance 3 IP: " IP3

echo ""
echo "👥 Team Assignment:"
echo "=================="
echo "Team Member 1 → Instance 1 ($IP1)"
echo "Team Member 2 → Instance 2 ($IP2)"
echo "Team Member 3 → Instance 3 ($IP3)"

echo ""
echo "🔧 Choose what to do:"
echo "===================="
echo "1. SSH into Instance 1"
echo "2. SSH into Instance 2"
echo "3. SSH into Instance 3"
echo "4. Set up development workspace on all instances"
echo "5. Show development workflow"
echo "6. Exit"

read -p "Choose option (1-6): " choice

case $choice in
    1|2|3)
        eval IP=\$IP$choice
        if [ ! -z "$IP" ]; then
            echo ""
            echo "🔗 Connecting to Instance $choice ($IP)..."
            echo "📁 After connecting, your workflow will be:"
            echo "   1. Clone your repo: git clone https://github.com/YOUR-USERNAME/online-book-bazaar.git"
            echo "   2. cd online-book-bazaar"
            echo "   3. Start coding!"
            echo ""
            ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ubuntu@$IP
        else
            echo "❌ No IP provided for instance $choice"
        fi
        ;;
    4)
        echo ""
        echo "🔧 Setting up development workspace on all instances..."
        
        for i in 1 2 3; do
            eval IP=\$IP$i
            if [ ! -z "$IP" ]; then
                echo "📦 Setting up Instance $i ($IP)..."
                ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ubuntu@$IP << 'EOF'
                    # Install basic development tools
                    sudo apt-get update -y
                    sudo apt-get install -y git vim nano htop tree curl wget
                    
                    # Install Node.js (if needed)
                    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
                    sudo apt-get install -y nodejs
                    
                    # Install Python tools (if needed)
                    sudo apt-get install -y python3 python3-pip
                    
                    echo "✅ Development tools installed!"
                    echo "📁 You can now clone your repository and start working"
EOF
                echo "✅ Instance $i setup complete!"
            fi
        done
        ;;
    5)
        echo ""
        echo "📖 Simple Development Workflow:"
        echo "==============================="
        echo ""
        echo "🔑 1. SSH into your assigned instance:"
        echo "   ssh -i $KEY_FILE ubuntu@<your-instance-ip>"
        echo ""
        echo "📂 2. Clone your project (first time only):"
        echo "   git clone https://github.com/YOUR-USERNAME/online-book-bazaar.git"
        echo "   cd online-book-bazaar"
        echo ""
        echo "💻 3. Start working:"
        echo "   git pull                    # Get latest changes"
        echo "   git checkout -b feature/my-feature  # Create your branch"
        echo "   # Edit files with nano, vim, or any text editor"
        echo "   npm install                 # Install dependencies (if Node.js)"
        echo "   npm start                   # Run your application"
        echo ""
        echo "💾 4. Save your work:"
        echo "   git add ."
        echo "   git commit -m 'Added my feature'"
        echo "   git push origin feature/my-feature"
        echo ""
        echo "🔄 5. Team collaboration:"
        echo "   • Each team member works on their own instance"
        echo "   • Use different Git branches for different features"
        echo "   • Create pull requests on GitHub for code review"
        echo "   • Regularly pull changes from main branch"
        ;;
    6)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid option"
        ;;
esac
