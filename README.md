# Online Book Bazaar - Team Development Setup

This project creates 3 EC2 instances on AWS for your team to collaboratively develop the Online Book Bazaar website. Each team member gets their own instance to work on.

## 🎯 What This Setup Provides

- **3 EC2 Instances** - One for each team member
- **SSH Access** - Direct access to work on the code
- **Development Tools** - Git, Node.js, Python pre-installed
- **Simple Workflow** - No complicated setup needed

---

## 📋 Step-by-Step Instructions

### **Step 1: Get Your Instance Information**

After Terraform creates the instances, you need to find their IP addresses:

1. **Go to AWS Console**:
   - Open [AWS Console](https://console.aws.amazon.com/)
   - Go to **EC2** → **Instances**

2. **Find Your Instances**:
   - Look for instances named: `book-bazaar-instance-1`, `book-bazaar-instance-2`, `book-bazaar-instance-3`
   - Note down their **Public IP addresses**

3. **Assign Team Members**:
   - **Team Member 1** → Instance 1 (IP: xxx.xxx.xxx.xxx)
   - **Team Member 2** → Instance 2 (IP: xxx.xxx.xxx.xxx)  
   - **Team Member 3** → Instance 3 (IP: xxx.xxx.xxx.xxx)

---

### **Step 2: Download the Key File**

1. **Download** the `team-key-mumbai.pem` file to your computer
2. **Place it** in a safe folder (like your Desktop or Documents)
3. **Remember the location** - you'll need it for SSH

---

### **Step 3: Connect to Your Instance**

Each team member should connect to their assigned instance:

#### **For Mac/Linux Users:**

```bash
# Open Terminal and run:
ssh -i /path/to/team-key-mumbai.pem ubuntu@YOUR-INSTANCE-IP

# Example:
ssh -i ~/Desktop/team-key-mumbai.pem ubuntu@13.232.123.45
```

#### **For Windows Users:**

**Option A: Using Command Prompt/PowerShell:**
```cmd
ssh -i C:\path\to\team-key-mumbai.pem ubuntu@YOUR-INSTANCE-IP
```

**Option B: Using PuTTY:**
1. Download PuTTY from [putty.org](https://www.putty.org/)
2. Convert the `.pem` file to `.ppk` using PuTTYgen
3. Use PuTTY to connect with the converted key

---

### **Step 4: Set Up Your Development Environment**

Once connected to your instance, run these commands **one time only**:

```bash
# Update the system
sudo apt-get update -y

# Install development tools
sudo apt-get install -y git vim nano htop tree curl wget

# Install Node.js (for web development)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Python tools (if needed)
sudo apt-get install -y python3 python3-pip

# Verify installations
node --version
npm --version
git --version
```

---

### **Step 5: Clone Your Project**

**First time only** - clone your Online Book Bazaar repository:

```bash
# Clone your repository (replace with your actual repo URL)
git clone https://github.com/YOUR-USERNAME/online-book-bazaar.git

# Go into the project folder
cd online-book-bazaar

# Install project dependencies
npm install
# OR if it's a Python project:
# pip3 install -r requirements.txt
```

---

### **Step 6: Daily Development Workflow**

Every time you want to work on the project:

#### **A. Connect to Your Instance**
```bash
ssh -i /path/to/team-key-mumbai.pem ubuntu@YOUR-INSTANCE-IP
cd online-book-bazaar
```

#### **B. Get Latest Changes**
```bash
git pull origin main
```

#### **C. Create Your Feature Branch**
```bash
git checkout -b feature/your-feature-name
# Example: git checkout -b feature/add-shopping-cart
```

#### **D. Make Your Changes**
```bash
# Edit files using nano or vim
nano index.html
# OR
vim app.js

# Test your changes
npm start
# OR for Python:
# python3 app.py
```

#### **E. Save Your Work**
```bash
# Add your changes
git add .

# Commit with a message
git commit -m "Add shopping cart functionality"

# Push to GitHub
git push origin feature/your-feature-name
```

#### **F. Create Pull Request**
1. Go to your GitHub repository
2. Click "Compare & pull request"
3. Add description of your changes
4. Request review from teammates
5. Merge after approval

---

### **Step 7: Team Collaboration**

#### **Branch Strategy:**
- `main` - Production ready code
- `feature/member1-feature` - Team member 1's work
- `feature/member2-feature` - Team member 2's work  
- `feature/member3-feature` - Team member 3's work

#### **Daily Sync:**
```bash
# Start each day by getting latest changes
git checkout main
git pull origin main
git checkout your-branch
git merge main  # Merge latest changes into your branch
```

#### **Code Review Process:**
1. Create pull request when feature is complete
2. Other team members review the code
3. Discuss and make changes if needed
4. Merge to main branch after approval

---

## 🛠️ Helper Scripts

We've provided some helper scripts to make things easier:

### **Simple Connection Script**
```bash
./simple-connect.sh
```
This script helps you:
- Connect to any instance easily
- Set up development tools
- See the workflow guide

---

## 🔧 Troubleshooting

### **Can't Connect via SSH?**
1. Check if the IP address is correct
2. Make sure the `.pem` file has correct permissions:
   ```bash
   chmod 400 team-key-mumbai.pem
   ```
3. Ensure your instance is running in AWS Console

### **Permission Denied Errors?**
```bash
# Fix permissions for the key file
chmod 400 /path/to/team-key-mumbai.pem
```

### **Git Push Fails?**
```bash
# Configure git (first time only)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### **Port Already in Use?**
```bash
# Kill any running processes
pkill -f node
# OR
pkill -f python
```

---

## 📱 Quick Reference

### **Essential Commands:**
```bash
# Connect to instance
ssh -i team-key-mumbai.pem ubuntu@YOUR-IP

# Navigate to project
cd online-book-bazaar

# Git commands
git status          # Check current status
git pull            # Get latest changes  
git add .           # Stage changes
git commit -m "msg" # Commit changes
git push            # Upload changes

# Development
npm install         # Install dependencies
npm start          # Start application
npm run dev        # Start in development mode
```

### **File Editing:**
```bash
nano filename.txt   # Easy editor for beginners
vim filename.txt    # Advanced editor
```

### **Useful Commands:**
```bash
ls                  # List files
pwd                 # Show current directory
cd folder-name      # Go into folder
cd ..              # Go back one folder
```

---

## 🎉 You're Ready to Start!

1. **Each team member** connects to their assigned instance
2. **Clone the repository** (first time only)
3. **Start coding** using the daily workflow
4. **Collaborate** through Git branches and pull requests

Happy coding! 🚀