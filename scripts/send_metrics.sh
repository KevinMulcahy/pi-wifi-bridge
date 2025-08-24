#!/bin/bash
# Metrics Collection Script
# Sends comprehensive metrics to ELK stack

while true; do
  # Collect metrics
  CPU_TEMP=$(vcgencmd measure_temp | cut -d'=' -f2 | cut -d"'" -f1)
  CPU_LOAD=$(cat /proc/loadavg | awk '{print $1}')
  MEM_USAGE=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')

  # Network metrics
  ETH_RX_BYTES=$(cat /sys/class/net/eth0/statistics/rx_bytes)
  ETH_TX_BYTES=$(cat /sys/class/net/eth0/statistics/tx_bytes)
  WIFI_RX_BYTES=$(cat /sys/class/net/wlan0/statistics/rx_bytes)
  WIFI_TX_BYTES=$(cat /sys/class/net/wlan0/statistics/tx_bytes)

  # WiFi quality metrics
  WIFI_SIGNAL=$(iwconfig wlan0 | grep "Signal level" | awk '{print $4}' | cut -d'=' -f2)
  WIFI_QUALITY=$(iwconfig wlan0 | grep "Link Quality" | awk '{print $2}' | cut -d'=' -f2)

  # VRRP state
  if ip addr show eth0 | grep -q "192.168.100.100"; then
    VRRP_STATE="MASTER"
  else
    VRRP_STATE="BACKUP"
  fi

  # Send to Elasticsearch
  curl -X POST http://10.0.0.40:9200/rpi-bridge-metrics/_doc \
    -H 'Content-Type: application/json' \
    -d "{
      \"@timestamp\": \"$(date -Iseconds)\",
      \"bridge_id\": \"$(hostname)\",
      \"cpu_temperature\": $CPU_TEMP,
      \"cpu_load\": $CPU_LOAD,
      \"memory_usage_percent\": $MEM_USAGE,
      \"network\": {
        \"eth0\": {
          \"rx_bytes\": $ETH_RX_BYTES,
          \"tx_bytes\": $ETH_TX_BYTES
        },
        \"wlan0\": {
          \"rx_bytes\": $WIFI_RX_BYTES,
          \"tx_bytes\": $WIFI_TX_BYTES,
          \"signal_dbm\": $WIFI_SIGNAL,
          \"quality\": \"$WIFI_QUALITY\"
        }
      },
      \"vrrp_state\": \"$VRRP_STATE\"
    }" 2>/dev/null || true

  sleep 60
done