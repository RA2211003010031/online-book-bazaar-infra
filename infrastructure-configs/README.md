# 📁 Infrastructure Configuration Files

This directory contains all the configuration files, scripts, and code used in the **Online Book Bazaar DevOps Infrastructure**. Perfect for demonstrations, reports, and video presentations.

## 📂 Directory Structure

```
infrastructure-configs/
├── ansible/                 # Ansible automation
│   ├── inventory.ini        # Server inventory
│   ├── playbook.yml         # Main playbook
│   └── ansible.cfg          # Ansible configuration
├── jenkins/                 # CI/CD pipeline
│   ├── automated-deployment-pipeline.groovy
│   └── jenkins-config.md
├── prometheus/              # Monitoring configuration
│   ├── prometheus.yml       # Main config
│   ├── alert_rules.yml      # Alerting rules
│   └── prometheus.service   # Systemd service
├── grafana/                 # Visualization
│   ├── grafana.ini          # Main config
│   ├── datasources.yml      # Data sources
│   └── dashboard-infrastructure.json
├── docker/                  # Containerization
│   ├── Dockerfile           # Application container
│   ├── docker-compose.yml   # Multi-service setup
│   └── .dockerignore        # Docker ignore rules
├── terraform/               # Infrastructure as Code
│   ├── main.tf              # Main infrastructure
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Output values
│   └── versions.tf          # Provider versions
└── scripts/                 # Automation scripts
    ├── unified-devops-setup.sh
    ├── node_exporter.service
    └── deploy-app.sh
```

## 🛠️ Configuration Details

### 📟 Ansible Configuration
- **Purpose**: Infrastructure automation and configuration management
- **Files**: 
  - `inventory.ini` - Defines all servers (Jenkins, App, Monitoring)
  - `playbook.yml` - Complete setup automation
  - `ansible.cfg` - Ansible runtime configuration

### 🏗️ Jenkins Configuration
- **Purpose**: CI/CD pipeline automation
- **Files**:
  - `automated-deployment-pipeline.groovy` - Complete pipeline script
  - `jenkins-config.md` - Setup and configuration guide

### 📊 Prometheus Configuration
- **Purpose**: Metrics collection and monitoring
- **Files**:
  - `prometheus.yml` - Scraping configuration for all services
  - `alert_rules.yml` - Alerting rules for infrastructure
  - `prometheus.service` - Systemd service configuration

### 📈 Grafana Configuration
- **Purpose**: Metrics visualization and dashboards
- **Files**:
  - `grafana.ini` - Main Grafana configuration
  - `datasources.yml` - Prometheus data source setup
  - `dashboard-infrastructure.json` - Pre-built infrastructure dashboard

### 🐳 Docker Configuration
- **Purpose**: Application containerization
- **Files**:
  - `Dockerfile` - Multi-stage production-ready container
  - `docker-compose.yml` - Complete stack deployment
  - `.dockerignore` - Optimized build context

### 🏗️ Terraform Configuration
- **Purpose**: Infrastructure as Code (AWS)
- **Files**:
  - `main.tf` - VPC, EC2, Security Groups
  - `variables.tf` - Configurable parameters
  - `outputs.tf` - Infrastructure outputs
  - `versions.tf` - Provider requirements

### 📜 Scripts
- **Purpose**: Automation and deployment scripts
- **Files**:
  - `unified-devops-setup.sh` - Complete infrastructure setup
  - `node_exporter.service` - System metrics collection
  - `deploy-app.sh` - Application deployment automation

## 🚀 Infrastructure Overview

### 🌐 **Live URLs**
- **Application**: http://43.205.253.129:8000
- **Jenkins**: http://13.232.244.171:8080
- **Grafana**: http://13.232.74.85:3000
- **Prometheus**: http://13.232.74.85:9090

### 🏗️ **Architecture**
```
┌─────────────────────────────────────────────────────────────┐
│                        AWS VPC                             │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ │
│  │   App Server    │ │ Jenkins Server  │ │ Monitor Server  │ │
│  │ 43.205.253.129  │ │ 13.232.244.171 │ │ 13.232.74.85   │ │
│  │                 │ │                 │ │                 │ │
│  │ • Book Bazaar   │ │ • Jenkins       │ │ • Prometheus    │ │
│  │ • Node Exporter │ │ • Docker        │ │ • Grafana       │ │
│  │ • Docker        │ │ • Node Exporter │ │ • Node Exporter │ │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 🔄 **CI/CD Workflow**
```
GitHub Push → Jenkins Webhook → Build → Test → Docker → Deploy → Monitor
```

## 📋 Usage Instructions

### 🎬 **For Video Demonstrations**

1. **Show Infrastructure Code**:
   ```bash
   # Show Terraform infrastructure
   cat infrastructure-configs/terraform/main.tf
   
   # Show Ansible automation
   cat infrastructure-configs/ansible/playbook.yml
   ```

2. **Show CI/CD Pipeline**:
   ```bash
   # Show Jenkins pipeline
   cat infrastructure-configs/jenkins/automated-deployment-pipeline.groovy
   ```

3. **Show Monitoring Setup**:
   ```bash
   # Show Prometheus config
   cat infrastructure-configs/prometheus/prometheus.yml
   
   # Show Grafana dashboard
   cat infrastructure-configs/grafana/dashboard-infrastructure.json
   ```

### 📄 **For Reports**

1. **Infrastructure as Code**: Reference `terraform/` files
2. **Configuration Management**: Reference `ansible/` files
3. **CI/CD Implementation**: Reference `jenkins/` files
4. **Monitoring Setup**: Reference `prometheus/` and `grafana/` files
5. **Containerization**: Reference `docker/` files

### 🧪 **For Testing**

1. **Deploy Infrastructure**:
   ```bash
   cd terraform/
   terraform init
   terraform plan
   terraform apply
   ```

2. **Configure Servers**:
   ```bash
   cd ansible/
   ansible-playbook -i inventory.ini playbook.yml
   ```

3. **Deploy Application**:
   ```bash
   cd scripts/
   ./deploy-app.sh
   ```

## 🏆 **DevOps Best Practices Demonstrated**

### ✅ **Infrastructure as Code**
- Terraform for cloud resource management
- Version-controlled infrastructure
- Reproducible environments

### ✅ **Configuration Management**
- Ansible for server configuration
- Idempotent automation
- Consistent environments

### ✅ **Continuous Integration/Continuous Deployment**
- Jenkins pipeline automation
- Automated testing and deployment
- GitHub integration

### ✅ **Monitoring & Observability**
- Prometheus metrics collection
- Grafana visualization
- Real-time monitoring

### ✅ **Containerization**
- Docker for application packaging
- Multi-stage builds
- Production-ready containers

### ✅ **Security**
- Non-root containers
- SSH key management
- Security group configurations

## 📞 **Support Information**

- **GitHub Repository**: https://github.com/RA2211003010031/website-book-store
- **Infrastructure Repo**: Local DevOps setup
- **Documentation**: All files include comprehensive comments

## 🎉 **Success Metrics**

- ✅ **100% Automated Deployment**
- ✅ **Zero-Downtime Deployments**
- ✅ **Real-time Monitoring**
- ✅ **Infrastructure as Code**
- ✅ **Complete CI/CD Pipeline**

---

**Perfect for DevOps demonstrations, interviews, and learning!** 🚀
