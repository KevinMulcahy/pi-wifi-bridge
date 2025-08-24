#!/bin/bash
# Main WiFi Bridge Setup Script
# Handles both primary and secondary configuration

set -e

# Check for role parameter
if [ $# -eq 0 ]; then
  echo "Usage: $0 [primary|secondary]"
  exit 1
fi

ROLE=$1
if [ "$ROLE" != "primary" ] && [ "$ROLE" != "secondary" ]; then
  echo "Error: Role must be 'primary' or 'secondary'"
  exit 1
fi

echo "=== WiFi Bridge Setup ($ROLE) ==="

# Get configuration parameters
read -p "Enter WiFi SSID: " WIFI_SSID
read -s -p "Enter WiFi password: " WIFI_PASSWORD
echo

# Set role-specific parameters
if [ "$ROLE" = "primary" ]; then
  ETH_IP="192.168.100.10"
  PRIORITY=110
  STATE="MASTER"
  ROUTER_ID="RPi_PRIMARY"
else
  ETH_IP="192.168.100.11"
  PRIORITY=100
  STATE="BACKUP"
  ROUTER_ID="RPi_SECONDARY"
fi

echo "Configuring as $STATE with IP $ETH_IP and priority $PRIORITY..."

# Create log directory
sudo mkdir -p /var/log
sudo touch /var/log/wifi_bridge.log /var/log/system_stats.log
sudo chown pi:pi /var/log/wifi_bridge.log /var/log/system_stats.log

# Configure network interfaces
sudo tee /etc/dhcpcd.conf > /dev/null <<EOF
interface eth0
static ip_address=${ETH_IP}/24
static routers=192.168.100.1
static domain_name_servers=192.168.100.1 8.8.8.8

interface wlan0
EOF

# Configure WiFi
sudo tee /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null <<EOF
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
  ssid="$WIFI_SSID"
  psk="$WIFI_PASSWORD"
  priority=10
  id_str="primary_wifi"
}
EOF

# Apply network settings
echo "Applying network configuration..."
sudo systemctl restart dhcpcd
sudo systemctl restart wpa_supplicant

# Configure system optimizations
echo "Applying system optimizations..."
sudo tee -a /etc/sysctl.conf > /dev/null <<EOF
# WiFi Bridge Optimizations
net.ipv4.ip_forward=1
net.ipv4.conf.all.send_redirects=0
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 65536 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.core.netdev_max_backlog=5000
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_sack=1
EOF

sudo sysctl -p

# Configure keepalived
echo "Configuring high availability..."
sudo tee /etc/keepalived/keepalived.conf > /dev/null <<EOF
global_defs {
  router_id $ROUTER_ID
  script_user root
  enable_script_security
}

vrrp_script chk_wifi_connection {
  script "/usr/local/bin/check_wifi.sh"
  interval 5
  timeout 3
  weight -15
  fall 3
  rise 2
}

vrrp_script chk_internet_connectivity {
  script "/usr/local/bin/check_internet.sh"
  interval 10
  timeout 5
  weight -10
  fall 2
  rise 1
}

vrrp_script chk_bridge_performance {
  script "/usr/local/bin/check_performance.sh"
  interval 30
  timeout 10
  weight -5
  fall 2
  rise 1
}

vrrp_instance VI_WIFI_BRIDGE {
  state $STATE
  interface eth0
  virtual_router_id 51
  priority $PRIORITY
  advert_int 1
  preempt_delay 10
  authentication {
    auth_type PASS
    auth_pass fuzzing_lab_ha_2023
  }
  virtual_ipaddress {
    192.168.100.100/24
  }
  track_script {
    chk_wifi_connection
    chk_internet_connectivity
    chk_bridge_performance
  }
  notify_master "/usr/local/bin/become_master.sh"
  notify_backup "/usr/local/bin/become_backup.sh"
  notify_fault "/usr/local/bin/fault_handler.sh"
}
EOF

# Apply firewall rules
echo "Applying security rules..."
./scripts/security_rules.sh

# Enable and start services
echo "Starting services..."
sudo systemctl enable keepalived
sudo systemctl start keepalived

# Add monitoring cron jobs
(crontab -l 2>/dev/null; echo "*/5 * * * * /home/pi/pi-wifi-bridge/scripts/system_monitor.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 6 * * * /home/pi/pi-wifi-bridge/scripts/daily_health_check.sh") | crontab -
(crontab -l 2>/dev/null; echo "*/15 * * * * /home/pi/pi-wifi-bridge/scripts/wifi_auto_select.sh") | crontab -

echo "=== WiFi Bridge Setup Complete ==="
echo "Bridge IP: $ETH_IP"
echo "VRRP VIP: 192.168.100.100"
echo "Role: $STATE"
echo "Priority: $PRIORITY"
echo ""
echo "Next steps:"
echo "1. Verify WiFi connectivity: iwconfig wlan0"
echo "2. Check keepalived status: sudo systemctl status keepalived"
echo "3. Monitor logs: tail -f /var/log/wifi_bridge.log"
echo "4. Test failover by disconnecting primary bridge"
