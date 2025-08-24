#!/bin/bash
# WiFi Connection Health Check Script
# Verifies wlan0 is up, associated, has IP, and checks signal strength

LOG_FILE="/var/log/wifi_bridge.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

log_message() {
  echo "[$TIMESTAMP] $1" >> $LOG_FILE
}

# Check if WiFi interface is up
if ! ip link show wlan0 | grep -q "state UP"; then
  log_message "ERROR: WiFi interface wlan0 is down"
  exit 1
fi

# Check WiFi association
if ! iwconfig wlan0 | grep -q "Access Point"; then
  log_message "ERROR: WiFi not associated with access point"
  exit 1
fi

# Check signal strength
SIGNAL=$(iwconfig wlan0 | grep "Signal level" | awk '{print $4}' | cut -d'=' -f2 | cut -d'd' -f1)
if [[ ! -z "$SIGNAL" ]] && [[ "$SIGNAL" -lt "-75" ]]; then
  log_message "WARNING: Poor WiFi signal strength: ${SIGNAL}dBm"
  exit 1
fi

# Check IP address assignment
if ! ip addr show wlan0 | grep -q "inet "; then
  log_message "ERROR: WiFi interface has no IP address"
  exit 1
fi

log_message "INFO: WiFi connection healthy - Signal: ${SIGNAL}dBm"
exit 0