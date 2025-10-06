#!/bin/bash

# Quick status check for Online Book Bazaar DevOps setup
# Usage: ./check-status.sh

# Instance IPs from Terraform (updated)
INSTANCE1_IP="43.205.253.129"   # App server
INSTANCE2_IP="13.232.244.171"   # Jenkins server  
INSTANCE3_IP="13.232.74.85"     # Monitoring server

# Ports
APP_PORT=8000
JENKINS_PORT=8080
PROMETHEUS_PORT=9090
GRAFANA_PORT=3000

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

check_service() {
    local ip=$1
    local port=$2
    local service=$3
    
    if curl -s --connect-timeout 5 http://$ip:$port > /dev/null; then
        echo -e "${GREEN}✓ $service (http://$ip:$port) - RUNNING${NC}"
        return 0
    else
        echo -e "${RED}✗ $service (http://$ip:$port) - NOT ACCESSIBLE${NC}"
        return 1
    fi
}

echo -e "${BLUE}=== Online Book Bazaar DevOps Status ===${NC}"
echo ""

echo "🚀 Application Services:"
check_service $INSTANCE1_IP $APP_PORT "Book Bazaar App"
echo ""

echo "🔧 Jenkins CI/CD:"
check_service $INSTANCE2_IP $JENKINS_PORT "Jenkins"
echo ""

echo "📊 Monitoring Stack:"
check_service $INSTANCE3_IP $PROMETHEUS_PORT "Prometheus"
check_service $INSTANCE3_IP $GRAFANA_PORT "Grafana"
echo ""

echo "📱 Access URLs:"
echo "• Book Bazaar App: http://$INSTANCE1_IP:$APP_PORT"
echo "• Jenkins: http://$INSTANCE2_IP:$JENKINS_PORT"
echo "• Prometheus: http://$INSTANCE3_IP:$PROMETHEUS_PORT"
echo "• Grafana: http://$INSTANCE3_IP:$GRAFANA_PORT (admin/admin123)"
