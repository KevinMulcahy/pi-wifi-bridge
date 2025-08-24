#!/bin/bash
# Network Recovery Script
# Automated network recovery procedures

LOG_FILE="/var/log/wifi_bridge.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] RECOVERY: Starting network recovery procedure..." >> $LOG_FILE

# Step 1: Restart network services
echo "[$TIMESTAMP] RECOVERY: Restarting network services..." >> $LOG_FILE
sudo systemctl restart dhcpcd
sudo systemctl restart wpa_supplicant
sleep 10

# Step 2: Reset WiFi interface
echo "[$TIMESTAMP] RECOVERY: Resetting WiFi interface..." >> $LOG_FILE
sudo ifdown wlan0
sleep 5
sudo ifup wlan0
sleep 15

# Step 3: Renew DHCP lease
echo "[$TIMESTAMP] RECOVERY: Renewing DHCP lease..." >> $LOG_FILE
sudo dhclient -r wlan0
sudo dhclient wlan0

# Step 4: Test connectivity
echo "[$TIMESTAMP] RECOVERY: Testing connectivity..." >> $LOG_FILE
if ping -c 3 8.8.8.8 > /dev/null 2>&1; then
  echo "[$TIMESTAMP] RECOVERY: Network recovery successful" >> $LOG_FILE
  sudo systemctl restart keepalived
  exit 0
else
  echo "[$TIMESTAMP] RECOVERY: Network recovery failed" >> $LOG_FILE
  curl -X POST http://10.0.0.40:9200/bridge-alerts/_doc \
    -H 'Content-Type: application/json' \
    -d "{
      \"timestamp\": \"$(date -Iseconds)\",
      \"severity\": \"critical\",
      \"bridge_id\": \"$(hostname)\",
      \"message\": \"Network recovery failed - manual intervention required\"
    }" 2>/dev/null || true
  exit 1
fi