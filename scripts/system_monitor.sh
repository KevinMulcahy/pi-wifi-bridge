#!/bin/bash
# System Monitoring Script
# Collects and logs comprehensive system metrics

LOG_FILE="/var/log/system_stats.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Collect system metrics
CPU_TEMP=$(vcgencmd measure_temp | cut -d'=' -f2 | cut -d"'" -f1)
CPU_LOAD=$(uptime | awk '{print $10}' | cut -d',' -f1)
MEM_USAGE=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)

# Network statistics
ETH_RX=$(cat /sys/class/net/eth0/statistics/rx_bytes)
ETH_TX=$(cat /sys/class/net/eth0/statistics/tx_bytes)
WIFI_RX=$(cat /sys/class/net/wlan0/statistics/rx_bytes)
WIFI_TX=$(cat /sys/class/net/wlan0/statistics/tx_bytes)

# WiFi signal info
WIFI_SIGNAL=$(iwconfig wlan0 | grep "Signal level" | awk '{print $4}' | cut -d'=' -f2)
WIFI_SSID=$(iwconfig wlan0 | grep "ESSID" | cut -d':' -f2 | tr -d '"')

# Log to local file
echo "[$TIMESTAMP] STATS: CPU_TEMP=${CPU_TEMP}°C CPU_LOAD=$CPU_LOAD MEM=${MEM_USAGE}% DISK=${DISK_USAGE}% ETH_RX=$ETH_RX ETH_TX=$ETH_TX WIFI_RX=$WIFI_RX WIFI_TX=$WIFI_TX SIGNAL=$WIFI_SIGNAL SSID=$WIFI_SSID" >> $LOG_FILE

# Send to monitoring system (if available)
curl -X POST http://10.0.0.40:9200/bridge-metrics/_doc \
  -H 'Content-Type: application/json' \
  -d "{
    \"timestamp\": \"$(date -Iseconds)\",
    \"bridge_id\": \"$(hostname)\",
    \"cpu_temp\": $CPU_TEMP,
    \"cpu_load\": $CPU_LOAD,
    \"memory_usage\": $MEM_USAGE,
    \"disk_usage\": $DISK_USAGE,
    \"eth_rx_bytes\": $ETH_RX,
    \"eth_tx_bytes\": $ETH_TX,
    \"wifi_rx_bytes\": $WIFI_RX,
    \"wifi_tx_bytes\": $WIFI_TX,
    \"wifi_signal\": \"$WIFI_SIGNAL\",
    \"wifi_ssid\": \"$WIFI_SSID\"
  }" 2>/dev/null || true