#!/bin/bash
# WiFi Auto-Selection Script
# Automatically scans and connects to the best available network

LOG_FILE="/var/log/wifi_bridge.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

select_best_wifi() {
  # Scan available networks
  sudo iwlist wlan0 scan | grep -E "(ESSID|Signal level)" > /tmp/wifi_scan.txt

  # Known networks with priorities (SSID:priority)
  KNOWN_NETWORKS=("PrimaryWiFi:10" "BackupWiFi:5" "GuestWiFi:1")
  BEST_NETWORK=""
  BEST_SIGNAL="-100"
  BEST_PRIORITY=0

  while IFS= read -r line; do
    if [[ $line == *"ESSID"* ]]; then
      CURRENT_SSID=$(echo $line | cut -d'"' -f2)
    elif [[ $line == *"Signal level"* ]]; then
      CURRENT_SIGNAL=$(echo $line | awk '{print $3}' | cut -d'=' -f2)
      for known in "${KNOWN_NETWORKS[@]}"; do
        ssid=${known%:*}
        priority=${known#*:}
        if [[ "$CURRENT_SSID" = "$ssid" ]]; then
          SCORE=$((CURRENT_SIGNAL + priority * 10))
          BEST_SCORE=$((BEST_SIGNAL + BEST_PRIORITY * 10))
          if [[ $SCORE -gt $BEST_SCORE ]]; then
            BEST_NETWORK=$ssid
            BEST_SIGNAL=$CURRENT_SIGNAL
            BEST_PRIORITY=$priority
          fi
        fi
      done
    fi
  done < /tmp/wifi_scan.txt

  if [[ ! -z "$BEST_NETWORK" ]]; then
    echo "[$TIMESTAMP] INFO: Best network found: $BEST_NETWORK (Signal: ${BEST_SIGNAL}dBm)" >> $LOG_FILE
    sudo wpa_cli -i wlan0 select_network $(wpa_cli -i wlan0 list_networks | grep "$BEST_NETWORK" | cut -f1)
    sleep 10
    if iwconfig wlan0 | grep -q "$BEST_NETWORK"; then
      echo "[$TIMESTAMP] INFO: Successfully connected to $BEST_NETWORK" >> $LOG_FILE
      return 0
    else
      echo "[$TIMESTAMP] ERROR: Failed to connect to $BEST_NETWORK" >> $LOG_FILE
      return 1
    fi
  else
    echo "[$TIMESTAMP] ERROR: No known networks available" >> $LOG_FILE
    return 1
  fi
}

# Auto-select best network if current connection is poor
CURRENT_SIGNAL=$(iwconfig wlan0 | grep "Signal level" | awk '{print $4}' | cut -d'=' -f2 | cut -d'd' -f1)
if [[ ! -z "$CURRENT_SIGNAL" ]] && [[ "$CURRENT_SIGNAL" -lt "-80" ]]; then
  echo "[$TIMESTAMP] INFO: Current signal poor ($CURRENT_SIGNAL dBm), searching for better network..." >> $LOG_FILE
  select_best_wifi
fi