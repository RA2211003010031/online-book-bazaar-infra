#!/bin/bash

# Manual Instance Connection Script
# Use this when you know your instance IPs but don't have local Terraform state

echo "🚀 Online Book Bazaar - Manual Instance Connection"
echo "=================================================="

# Check if key file exists
KEY_FILE="team-key-mumbai.pem"
if [ ! -f "$KEY_FILE" ]; then
    echo "❌ Error: Key file '$KEY_FILE' not found."
    echo "Make sure the key file is in the current directory."
    exit 1
fi

# Set correct permissions
chmod 400 "$KEY_FILE"

echo ""
echo "📋 To connect to your instances, you'll need their IP addresses."
echo "You can get these from:"
echo "1. AWS Console → EC2 → Instances"
echo "2. Terraform Cloud → Your workspace → Latest run → Outputs"
echo ""

# Get instance IPs from user
read -p "Enter instance 1 IP address: " IP1
read -p "Enter instance 2 IP address: " IP2  
read -p "Enter instance 3 IP address: " IP3

echo ""
echo "🖥️  Your Development Environment Access:"
echo "========================================"

# Display access information for each instance
for i in 1 2 3; do
    eval IP=\$IP$i
    if [ ! -z "$IP" ]; then
        echo ""
        echo "🔸 Instance $i ($IP):"
        echo "  • Web Interface: http://$IP"
        echo "  • VS Code in Browser: http://$IP/code/ (Password: bookbazaar2024)"
        echo "  • SSH Access: ssh -i $KEY_FILE ubuntu@$IP"
        echo "  • Development App: http://$IP/app/ (when server is running)"
    fi
done

echo ""
echo "🔧 Quick Actions:"
echo "================="
echo "1. Connect to instance 1"
echo "2. Connect to instance 2" 
echo "3. Connect to instance 3"
echo "4. Open development guide"
echo "5. Exit"

read -p "Choose an option (1-5): " choice

case $choice in
    1|2|3)
        eval IP=\$IP$choice
        if [ ! -z "$IP" ]; then
            echo "🔗 Connecting to Instance $choice ($IP)..."
            echo "📁 Project directory: /home/ubuntu/workspace/book-bazaar/"
            ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ubuntu@$IP
        else
            echo "❌ No IP provided for instance $choice"
        fi
        ;;
    4)
        echo ""
        echo "📖 Development Quick Guide:"
        echo "=========================="
        echo ""
        echo "🌐 VS Code in Browser:"
        echo "  1. Open http://<instance-ip>/code/"
        echo "  2. Password: bookbazaar2024"
        echo "  3. Navigate to /home/ubuntu/workspace/book-bazaar/"
        echo ""
        echo "💻 SSH Development:"
        echo "  1. SSH into your instance"
        echo "  2. cd /home/ubuntu/workspace/book-bazaar"
        echo "  3. git pull  # Get latest changes"
        echo "  4. git checkout -b feature/your-feature"
        echo "  5. # Make your changes"
        echo "  6. npm run dev  # Start development server"
        echo "  7. # Test at http://<instance-ip>/app/"
        echo "  8. git add . && git commit -m 'your changes'"
        echo "  9. git push origin feature/your-feature"
        echo ""
        echo "🔄 Team Collaboration:"
        echo "  • Each team member uses a different instance"
        echo "  • Work on different branches/features"
        echo "  • Use pull requests for code review"
        echo "  • Sync regularly with git pull"
        ;;
    5)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac
