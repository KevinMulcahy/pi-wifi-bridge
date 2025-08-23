#!/bin/bash
# Backup Demotion Script
# Executed when this bridge becomes BACKUP

LOG_FILE="/var/log/wifi_bridge.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] INFO: Becoming BACKUP bridge" >> $LOG_FILE

# Configure power-saving settings for backup role
echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Send notification to monitoring system
curl -X POST http://10.0.0.40:9200/bridge-events/_doc \
  -H 'Content-Type: application/json' \
  -d "{
    \"timestamp\": \"$(date -Iseconds)\",
    \"event\": \"backup_demotion\",
    \"bridge_id\": \"$(hostname)\",
    \"message\": \"Bridge demoted to backup role\"
  }" 2>/dev/null || true

echo "[$TIMESTAMP] INFO: Backup role configuration complete" >> $LOG_FILE