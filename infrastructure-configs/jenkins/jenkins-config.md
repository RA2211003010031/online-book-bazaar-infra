# Jenkins Configuration for Online Book Bazaar CI/CD Pipeline

## Jenkins System Configuration

### Basic Settings
- **Jenkins URL**: http://13.232.244.171:8080
- **Admin User**: admin
- **Java Version**: OpenJDK 11
- **Jenkins Home**: /var/lib/jenkins

### Required Plugins
```
- Git Plugin
- Pipeline Plugin
- Docker Pipeline Plugin
- GitHub Integration Plugin
- Blue Ocean Plugin (optional for better UI)
- Workspace Cleanup Plugin
```

### Global Tool Configuration
```
Git:
  Name: Default
  Path: git

Docker:
  Name: docker
  Installation root: /usr/bin/docker
```

### System Settings

#### Global Properties
```
Environment Variables:
- DOCKER_REGISTRY: local
- APP_SERVER_IP: 43.205.253.129
- MONITORING_SERVER: 13.232.74.85
```

#### GitHub Configuration
```
GitHub Servers:
- API URL: https://api.github.com
- Credentials: (if using private repos)
```

### Security Configuration
```
Security Realm: Jenkins' own user database
Authorization: Logged-in users can do anything
CSRF Protection: Enabled
```

### Pipeline Configuration

#### SCM Settings
```
Repository URL: https://github.com/RA2211003010031/website-book-store.git
Branch: main
Script Path: Jenkinsfile (or inline pipeline script)
```

#### Build Triggers
```
☑️ GitHub hook trigger for GITScm polling
☑️ Poll SCM: H/5 * * * * (every 5 minutes as fallback)
```

### Webhook Configuration
```
GitHub Webhook URL: http://13.232.244.171:8080/github-webhook/
Content Type: application/json
Events: Push events
```

### Build Environment
```
☑️ Delete workspace before build starts
☑️ Add timestamps to the Console Output
```

### Post-build Actions
```
- Archive artifacts: *.tar, *.log
- Cleanup workspace
- Send notifications (optional)
```
