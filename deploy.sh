#!/bin/bash

# Development Environment Management Script for Online Book Bazaar
# This script helps manage the development environment across all EC2 instances

# Configuration
GITHUB_REPO="${1:-https://github.com/your-username/online-book-bazaar.git}"
KEY_FILE="team-key-mumbai.pem"
WORKSPACE_DIR="/home/ubuntu/workspace/book-bazaar"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get instance IPs from Terraform output
echo -e "${YELLOW}Getting instance IPs from Terraform...${NC}"
INSTANCE_IPS=$(terraform output -json instance_public_ips | jq -r '.[]')

if [ -z "$INSTANCE_IPS" ]; then
    echo -e "${RED}Error: Could not get instance IPs. Make sure you've run 'terraform apply' first.${NC}"
    exit 1
fi

echo -e "${GREEN}Found development instances:${NC}"
for i, ip in $(echo "$INSTANCE_IPS" | nl); do
    echo -e "${BLUE}Instance $i: http://$ip${NC}"
    echo -e "  • VS Code: ${YELLOW}http://$ip/code/${NC}"
    echo -e "  • SSH: ${YELLOW}ssh -i $KEY_FILE ubuntu@$ip${NC}"
done

# Function to sync code to an instance
sync_code_to_instance() {
    local ip=$1
    echo -e "\n${YELLOW}Syncing code to instance: $ip${NC}"
    
    ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ubuntu@$ip << EOF
        set -e
        cd $WORKSPACE_DIR
        
        echo "Fetching latest changes from repository..."
        git fetch origin
        
        echo "Current branch: \$(git branch --show-current)"
        echo "Pulling latest changes..."
        git pull origin main || git pull origin master
        
        echo "Installing/updating dependencies..."
        if [ -f "package.json" ]; then
            npm install
        elif [ -f "requirements.txt" ]; then
            pip3 install -r requirements.txt
        fi
        
        echo "Code sync completed on $ip"
EOF
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Successfully synced code to $ip${NC}"
    else
        echo -e "${RED}✗ Failed to sync code to $ip${NC}"
    fi
}

# Function to start development server on an instance
start_dev_server() {
    local ip=$1
    echo -e "\n${YELLOW}Starting development server on: $ip${NC}"
    
    ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ubuntu@$ip << EOF
        set -e
        cd $WORKSPACE_DIR
        
        echo "Stopping any existing development server..."
        pkill -f "npm.*start" || true
        pkill -f "python.*manage.py" || true
        pkill -f "node.*server" || true
        
        echo "Starting development server..."
        if [ -f "package.json" ]; then
            # For Node.js projects
            npm run dev > /tmp/dev-server.log 2>&1 &
            echo "Started Node.js development server"
        elif [ -f "manage.py" ]; then
            # For Django projects
            python3 manage.py runserver 0.0.0.0:3000 > /tmp/dev-server.log 2>&1 &
            echo "Started Django development server"
        elif [ -f "app.py" ]; then
            # For Flask projects
            FLASK_ENV=development python3 app.py > /tmp/dev-server.log 2>&1 &
            echo "Started Flask development server"
        else
            echo "No recognized application structure found"
        fi
        
        sleep 2
        echo "Development server started. Access at: http://$ip/app/"
EOF
}

# Check if key file exists
if [ ! -f "$KEY_FILE" ]; then
    echo -e "${RED}Error: Key file '$KEY_FILE' not found.${NC}"
    echo "Make sure the key file is in the current directory and has the correct permissions (chmod 400)."
    exit 1
fi

# Set correct permissions for key file
chmod 400 "$KEY_FILE"

# Menu system
echo -e "\n${BLUE}=== Book Bazaar Development Environment Manager ===${NC}"
echo "1. Sync code to all instances"
echo "2. Start development servers on all instances"
echo "3. Access information for all instances"
echo "4. SSH into specific instance"
echo "5. Exit"

read -p "Choose an option (1-5): " choice

case $choice in
    1)
        echo -e "\n${YELLOW}Syncing code to all instances...${NC}"
        for ip in $INSTANCE_IPS; do
            sync_code_to_instance "$ip"
        done
        ;;
    2)
        echo -e "\n${YELLOW}Starting development servers on all instances...${NC}"
        for ip in $INSTANCE_IPS; do
            start_dev_server "$ip"
        done
        ;;
    3)
        echo -e "\n${GREEN}=== Development Environment Access Information ===${NC}"
        i=1
        for ip in $INSTANCE_IPS; do
            echo -e "\n${BLUE}🖥️  Instance $i:${NC}"
            echo -e "  🌐 Web Interface: ${YELLOW}http://$ip${NC}"
            echo -e "  💻 VS Code in Browser: ${YELLOW}http://$ip/code/${NC} (Password: bookbazaar2024)"
            echo -e "  🚀 Development App: ${YELLOW}http://$ip/app/${NC} (when server is running)"
            echo -e "  🔑 SSH Access: ${YELLOW}ssh -i $KEY_FILE ubuntu@$ip${NC}"
            echo -e "  📁 Project Path: ${YELLOW}$WORKSPACE_DIR${NC}"
            ((i++))
        done
        ;;
    4)
        echo -e "\n${BLUE}Available instances:${NC}"
        i=1
        for ip in $INSTANCE_IPS; do
            echo "$i. $ip"
            ((i++))
        done
        read -p "Choose instance number: " instance_num
        
        ip=$(echo "$INSTANCE_IPS" | sed -n "${instance_num}p")
        if [ ! -z "$ip" ]; then
            echo -e "${GREEN}Connecting to $ip...${NC}"
            echo -e "${YELLOW}Project directory: $WORKSPACE_DIR${NC}"
            ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ubuntu@$ip
        else
            echo -e "${RED}Invalid instance number${NC}"
        fi
        ;;
    5)
        echo -e "${GREEN}Goodbye!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac
