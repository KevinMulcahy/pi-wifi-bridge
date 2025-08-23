#!/bin/bash
# Internet Connectivity Check Script
# Pings multiple DNS servers to verify external reachability

LOG_FILE="/var/log/wifi_bridge.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

DNS_SERVERS=("8.8.8.8" "1.1.1.1" "208.67.222.222")
SUCCESS_COUNT=0

for dns in "${DNS_SERVERS[@]}"; do
  if ping -c 2 -W 3 $dns > /dev/null 2>&1; then
    ((SUCCESS_COUNT++))
  fi
done

if [[ $SUCCESS_COUNT -eq 0 ]]; then
  echo "[$TIMESTAMP] ERROR: No internet connectivity to any DNS server" >> $LOG_FILE
  exit 1
elif [[ $SUCCESS_COUNT -eq 1 ]]; then
  echo "[$TIMESTAMP] WARNING: Limited internet connectivity (1/${#DNS_SERVERS[@]} servers)" >> $LOG_FILE
  exit 0
else
  echo "[$TIMESTAMP] INFO: Internet connectivity OK (${SUCCESS_COUNT}/${#DNS_SERVERS[@]} servers)" >> $LOG_FILE
  exit 0
fi