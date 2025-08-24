#!/bin/bash
# Master Promotion Script
# Executed when this bridge becomes the MASTER

LOG_FILE="/var/log/wifi_bridge.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] CRITICAL: Becoming MASTER bridge" >> $LOG_FILE

# Configure optimized settings for master role
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Increase network buffer sizes
sudo sysctl -w net.core.rmem_max=16777216
sudo sysctl -w net.core.wmem_max=16777216

# Send notification to monitoring system
curl -X POST http://10.0.0.40:9200/bridge-events/_doc \
  -H 'Content-Type: application/json' \
  -d "{
    \"timestamp\": \"$(date -Iseconds)\",
    \"event\": \"master_promotion\",
    \"bridge_id\": \"$(hostname)\",
    \"message\": \"Bridge promoted to master role\"
  }" 2>/dev/null || true

echo "[$TIMESTAMP] INFO: Master role configuration complete" >> $LOG_FILE