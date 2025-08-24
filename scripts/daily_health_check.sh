#!/bin/bash
# Daily Health Check Script
# Generates comprehensive daily reports

LOG_FILE="/var/log/daily_health.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
REPORT_FILE="/tmp/health_report_$(date +%Y%m%d).txt"

echo "=== Daily Health Check - $TIMESTAMP ===" > $REPORT_FILE

# System Health
echo "## System Health" >> $REPORT_FILE
echo "CPU Temperature: $(vcgencmd measure_temp)" >> $REPORT_FILE
echo "CPU Load: $(uptime)" >> $REPORT_FILE
echo "Memory Usage: $(free -h)" >> $REPORT_FILE
echo "Disk Usage: $(df -h)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Network Health
echo "## Network Health" >> $REPORT_FILE
echo "WiFi Status: $(iwconfig wlan0 | grep -E '(ESSID|Signal level|Bit Rate)')" >> $REPORT_FILE
echo "Ethernet Status: $(ethtool eth0 | grep -E '(Speed|Duplex|Link detected)')" >> $REPORT_FILE
echo "IP Addresses:" >> $REPORT_FILE
ip addr show | grep "inet " | grep -v "127.0.0.1" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# VRRP Status
echo "## High Availability Status" >> $REPORT_FILE
echo "Keepalived Status: $(systemctl is-active keepalived)" >> $REPORT_FILE
if ip addr show eth0 | grep -q "192.168.100.100"; then
  echo "VRRP State: MASTER" >> $REPORT_FILE
else
  echo "VRRP State: BACKUP" >> $REPORT_FILE
fi
echo "" >> $REPORT_FILE

# Connectivity Tests
echo "## Connectivity Tests" >> $REPORT_FILE
ping -c 3 192.168.100.1 > /dev/null && echo "✓ pfSense gateway reachable" >> $REPORT_FILE || echo "✗ pfSense gateway unreachable" >> $REPORT_FILE
ping -c 3 8.8.8.8 > /dev/null && echo "✓ Internet connectivity OK" >> $REPORT_FILE || echo "✗ No internet connectivity" >> $REPORT_FILE
ping -c 3 10.0.0.40 > /dev/null && echo "✓ Monitoring server reachable" >> $REPORT_FILE || echo "✗ Monitoring server unreachable" >> $REPORT_FILE

# Log Analysis
echo "## Recent Issues" >> $REPORT_FILE
grep -i error /var/log/wifi_bridge.log | tail -5 >> $REPORT_FILE 2>/dev/null || echo "No recent errors" >> $REPORT_FILE

# Performance Metrics
echo "## Performance Metrics (Last 24h)" >> $REPORT_FILE
echo "Network Traffic:" >> $REPORT_FILE
echo " Ethernet RX: $(cat /sys/class/net/eth0/statistics/rx_bytes | numfmt --to=iec)" >> $REPORT_FILE
echo " Ethernet TX: $(cat /sys/class/net/eth0/statistics/tx_bytes | numfmt --to=iec)" >> $REPORT_FILE
echo " WiFi RX: $(cat /sys/class/net/wlan0/statistics/rx_bytes | numfmt --to=iec)" >> $REPORT_FILE
echo " WiFi TX: $(cat /sys/class/net/wlan0/statistics/tx_bytes | numfmt --to=iec)" >> $REPORT_FILE

# Send report to monitoring system
curl -X POST http://10.0.0.40:9200/bridge-health/_doc \
  -H 'Content-Type: application/json' \
  -d "{
    \"timestamp\": \"$(date -Iseconds)\",
    \"bridge_id\": \"$(hostname)\",
    \"report\": \"$(cat $REPORT_FILE | base64 -w 0)\"
  }" 2>/dev/null || echo "Could not send to monitoring system"

# Email report if configured
if command -v mail &> /dev/null; then
  mail -s "WiFi Bridge Health Report - $(hostname)" admin@company.com < $REPORT_FILE
fi

cat $REPORT_FILE >> $LOG_FILE
echo "[$TIMESTAMP] Daily health check completed" >> $LOG_FILE