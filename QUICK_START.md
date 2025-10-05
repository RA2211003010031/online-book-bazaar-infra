# 🚀 QUICK START GUIDE - DevOps Demo Setup

## ⚡ Get Started in 5 Minutes

### 📋 What You Need
- [x] 3 Running EC2 instances
- [x] SSH key file (`team-key-mumbai.pem`) in this directory
- [x] Instance IP addresses
- [x] GitHub repository URL

### 🎯 ONE COMMAND TO RULE THEM ALL

```bash
./automated-devops-setup.sh
```

**That's it!** This script will:
- ✅ Install Docker, Ansible, Jenkins, Prometheus, Grafana
- ✅ Deploy your application to all instances
- ✅ Set up monitoring dashboards
- ✅ Create CI/CD pipelines
- ✅ Provide all access URLs for your demo

---

## 📝 What the Script Will Ask You

1. **Instance 1 IP** (Jenkins + Development)
2. **Instance 2 IP** (Monitoring + Development)  
3. **Instance 3 IP** (Production + Development)
4. **GitHub Repository URL**
5. **GitHub Username**

---

## 🎬 After Script Completes

You'll get access to:

### 🌐 Application URLs
- **App Instance 1:** http://[IP1]:3000
- **App Instance 2:** http://[IP2]:3000
- **App Instance 3:** http://[IP3]:3000

### 🔧 DevOps Tools
- **Jenkins:** http://[IP1]:8080
- **Prometheus:** http://[IP2]:9090
- **Grafana:** http://[IP2]:3000

### 📚 Demo Materials
- **Recording Script:** `VIDEO_RECORDING_SCRIPT.md`
- **Troubleshooting:** `DEMO_TROUBLESHOOTING.md`
- **Access Info:** Generated `access-info.md`

---

## 🎥 Recording Your Demo

1. **Follow:** `VIDEO_RECORDING_SCRIPT.md`
2. **Duration:** 15-20 minutes
3. **Structure:** Clear phases with explanations
4. **Backup:** `DEMO_TROUBLESHOOTING.md` if needed

---

## 🆘 If Something Goes Wrong

1. **Check:** AWS Security Groups allow ports 22, 80, 3000, 8080, 9090
2. **Verify:** All instances are running
3. **Use:** `DEMO_TROUBLESHOOTING.md` for specific fixes
4. **Re-run:** Script is idempotent (safe to run multiple times)

---

## 💡 Pro Tips

- **Bookmark all URLs** before recording
- **Practice once** before final recording
- **Keep energy high** during presentation
- **Explain business value** of each tool
- **Stay confident** - you've built something amazing!

---

## 🏆 You're Ready!

Your complete DevOps environment is just one script away. Run it, test everything, and then record an amazing demo that will impress your teacher and showcase your skills!

**Good luck! 🚀**
