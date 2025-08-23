#!/bin/bash
# Performance Monitoring Script
# Monitors CPU load, memory usage, and network interface errors

LOG_FILE="/var/log/wifi_bridge.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Check CPU load
CPU_LOAD=$(uptime | awk '{print $10}' | cut -d',' -f1)
if (( $(echo "$CPU_LOAD > 2.0" | bc -l) )); then
  echo "[$TIMESTAMP] WARNING: High CPU load: $CPU_LOAD" >> $LOG_FILE
  exit 1
fi

# Check memory usage
MEM_USAGE=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
if (( $(echo "$MEM_USAGE > 85.0" | bc -l) )); then
  echo "[$TIMESTAMP] WARNING: High memory usage: ${MEM_USAGE}%" >> $LOG_FILE
  exit 1
fi

# Check network interface errors
ETH_ERRORS=$(cat /sys/class/net/eth0/statistics/rx_errors)
WIFI_ERRORS=$(cat /sys/class/net/wlan0/statistics/rx_errors)
if [[ "$ETH_ERRORS" -gt 100 ]] || [[ "$WIFI_ERRORS" -gt 100 ]]; then
  echo "[$TIMESTAMP] WARNING: Network interface errors detected" >> $LOG_FILE
  exit 1
fi

echo "[$TIMESTAMP] INFO: Performance check OK - CPU: $CPU_LOAD, MEM: ${MEM_USAGE}%" >> $LOG_FILE
exit 0