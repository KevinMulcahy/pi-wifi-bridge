#!/bin/bash
echo "=== Secondary WiFi Bridge Setup ==="
echo "This script will configure this Pi as the SECONDARY bridge (BACKUP)"
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root. Run with sudo when needed."
  exit 1
fi

# Install required packages
echo "Installing required packages..."
sudo apt update
sudo apt install -y keepalived iptables-persistent bridge-utils hostapd dnsmasq tcpdump iftop htop vim curl wget git bc

# Create directories
mkdir -p /home/pi/logs
chmod +x scripts/*.sh

# Copy scripts to system locations
echo "Installing scripts..."
sudo cp scripts/check_*.sh /usr/local/bin/
sudo cp scripts/become_*.sh /usr/local/bin/
sudo cp scripts/fault_handler.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/*.sh

# Run the main setup script
echo "Running secondary bridge configuration..."
./scripts/setup_wifi_bridge.sh secondary

echo ""
echo "=== Secondary Bridge Setup Complete ==="
echo "Next steps:"
echo "1. Verify WiFi connectivity: iwconfig wlan0"
echo "2. Check keepalived status: sudo systemctl status keepalived"
echo "3. Monitor logs: tail -f /var/log/wifi_bridge.log"
echo "4. Test failover by disconnecting primary bridge"