#!/bin/bash
# Emergency Recovery Script
# Complete system recovery for critical situations

echo "=== Emergency WiFi Bridge Recovery ==="

# Stop all services
sudo systemctl stop keepalived
sudo systemctl stop bridge-metrics 2>/dev/null || true

# Reset network interfaces
sudo ifdown eth0 wlan0
sleep 5
sudo ifup eth0 wlan0
sleep 10

# Clear and reapply iptables rules
sudo iptables -F
sudo iptables -t nat -F
/home/pi/pi-wifi-bridge/scripts/security_rules.sh

# Restart services
sudo systemctl start keepalived
sudo systemctl start bridge-metrics 2>/dev/null || true

# Test basic connectivity
ping -c 3 192.168.100.1
ping -c 3 8.8.8.8

echo "Emergency recovery completed"
echo "Check status: sudo systemctl status keepalived"