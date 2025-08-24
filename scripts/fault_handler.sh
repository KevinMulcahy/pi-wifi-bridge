#!/bin/bash
# Fault Handler Script
# Attempts automatic recovery when faults are detected

LOG_FILE="/var/log/wifi_bridge.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] CRITICAL: Bridge fault detected" >> $LOG_FILE
echo "[$TIMESTAMP] INFO: Attempting automatic recovery..." >> $LOG_FILE

# Restart network interfaces
sudo systemctl restart dhcpcd
sleep 5

# Restart WiFi
sudo ifdown wlan0 && sudo ifup wlan0
sleep 10

# Check if recovery successful
if /usr/local/bin/check_wifi.sh && /usr/local/bin/check_internet.sh; then
  echo "[$TIMESTAMP] INFO: Automatic recovery successful" >> $LOG_FILE
  exit 0
else
  echo "[$TIMESTAMP] ERROR: Automatic recovery failed" >> $LOG_FILE
  # Send critical alert
  curl -X POST http://10.0.0.40:9200/bridge-alerts/_doc \
    -H 'Content-Type: application/json' \
    -d "{
      \"timestamp\": \"$(date -Iseconds)\",
      \"severity\": \"critical\",
      \"bridge_id\": \"$(hostname)\",
      \"message\": \"Bridge fault - automatic recovery failed\"
    }" 2>/dev/null || true
  exit 1
fi