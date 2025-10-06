#!/bin/bash

# Fix Prometheus Monitoring Setup
# This script fixes the target health issues in Prometheus

echo "=== Fixing Prometheus Monitoring Setup ==="

# Instance IPs
MONITORING_IP="3.111.215.37"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Updating Prometheus configuration..."

# Create optimized Prometheus configuration
ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@${MONITORING_IP} "cat > /tmp/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'monitoring-server'
    static_configs:
      - targets: ['localhost:9100']
    scrape_interval: 30s
    metrics_path: /metrics
EOF"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Restarting Prometheus and Node Exporter with host networking..."

# Stop existing containers
ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@${MONITORING_IP} "sudo docker stop prometheus node-exporter 2>/dev/null || true"
ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@${MONITORING_IP} "sudo docker rm prometheus node-exporter 2>/dev/null || true"

# Start Node Exporter with host networking
ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@${MONITORING_IP} "sudo docker run -d --name node-exporter --net=host prom/node-exporter"

# Start Prometheus with host networking
ssh -i team-key-mumbai.pem -o StrictHostKeyChecking=no ubuntu@${MONITORING_IP} "sudo docker run -d --name prometheus --net=host -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Waiting for services to start..."
sleep 15

# Verify targets
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking target health..."
curl -s http://${MONITORING_IP}:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, instance: .labels.instance, health}'

echo ""
echo "✅ Prometheus monitoring setup completed!"
echo ""
echo "📊 Access URLs:"
echo "• Prometheus: http://${MONITORING_IP}:9090"
echo "• Grafana: http://${MONITORING_IP}:3000 (admin/admin123)"
echo ""
echo "🎯 All targets should now be UP in Prometheus UI"
