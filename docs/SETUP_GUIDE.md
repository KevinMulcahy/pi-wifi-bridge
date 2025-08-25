# Raspberry Pi WiFi Bridge - Complete Setup Guide

This guide provides a comprehensive setup for high-availability WiFi-to-Ethernet bridges using two Raspberry Pi 3B+ units with automatic failover and monitoring.

---

## 📦 Requirements

### Hardware (Per Unit)
- Raspberry Pi 3 B+
- MicroSD card (32GB Class 10 minimum)
- Ethernet cable (Cat6 recommended)
- Power supply (5V 2.5A minimum)
- Case with adequate ventilation
- Optional: External WiFi antenna for better range

### Network Requirements
- WiFi network with internet access
- Static IP allocation capability on WiFi network
- pfSense firewall WAN ports available
- Network switch or direct connection capability

### Software
- Raspberry Pi OS Lite (64-bit)
- keepalived
- iptables-persistent
- bridge-utils
- hostapd, dnsmasq

---

## 🛠️ Installation Steps

### Quick Setup (Recommended)

If you have access to the setup scripts, you can use the automated installation:

```bash
# Clone the repository (if available)
cd /home/pi
git clone https://github.com/your-org/pi-wifi-bridge.git
cd pi-wifi-bridge

# Run automated setup for Primary Pi
sudo ./setup_primary.sh

# Run automated setup for Secondary Pi  
sudo ./setup_secondary.sh
```

### Manual Installation

If you need to set up manually or customize the installation:

#### 1. Flash Raspberry Pi OS Lite

**Using Raspberry Pi Imager:**
- OS: Raspberry Pi OS Lite (64-bit)
- Enable SSH with password authentication
- Set username: `pi`
- Set password: [secure-password]
- Configure WiFi: [your-network-ssid]
- Set locale settings

#### 2. Initial System Setup

SSH to both Pi units and run:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y \
    bridge-utils \
    iptables-persistent \
    keepalived \
    hostapd \
    dnsmasq \
    tcpdump \
    iftop \
    htop \
    vim \
    curl \
    wget \
    git
```

#### 3. Download Setup Scripts

If scripts are available separately:

```bash
# Create project directory
mkdir -p /home/pi/pi-wifi-bridge
cd /home/pi/pi-wifi-bridge

# Download scripts (adjust URL as needed)
wget https://raw.githubusercontent.com/your-org/pi-wifi-bridge/main/setup_primary.sh
wget https://raw.githubusercontent.com/your-org/pi-wifi-bridge/main/setup_secondary.sh
wget https://raw.githubusercontent.com/your-org/pi-wifi-bridge/main/install_scripts.sh

# Make scripts executable
chmod +x *.sh
```

---

## 📥 Script Repository Setup

### Getting the Scripts

#### Option 1: Clone Repository
```bash
# If you have a GitHub repository set up
cd /home/pi
git clone https://github.com/your-org/pi-wifi-bridge.git
cd pi-wifi-bridge

# Make all scripts executable
chmod +x *.sh
```

#### Option 2: Download Individual Scripts
```bash
# Create project directory
mkdir -p /home/pi/pi-wifi-bridge
cd /home/pi/pi-wifi-bridge

# Download main setup scripts
wget https://raw.githubusercontent.com/your-org/pi-wifi-bridge/main/setup_primary.sh
wget https://raw.githubusercontent.com/your-org/pi-wifi-bridge/main/setup_secondary.sh
wget https://raw.githubusercontent.com/your-org/pi-wifi-bridge/main/install_scripts.sh

# Make executable
chmod +x *.sh
```

#### Option 3: Manual Script Creation
If you don't have access to a repository, you can create the scripts manually using the code provided in the [Automated Setup](#automated-setup) section below.

### Verifying Script Integrity

Before running any scripts, verify they're complete and safe:

```bash
# Check script exists and is executable
ls -la setup_primary.sh

# Review script content before execution
less setup_primary.sh

# Check for common issues
bash -n setup_primary.sh  # Syntax check
```

---

### Available Scripts

The following scripts are available to automate the setup process:

| Script | Purpose | Usage |
|--------|---------|-------|
| `setup_primary.sh` | Configure primary bridge | `sudo ./setup_primary.sh` |
| `setup_secondary.sh` | Configure secondary bridge | `sudo ./setup_secondary.sh` |
| `install_scripts.sh` | Install monitoring/health scripts | `sudo ./install_scripts.sh` |
| `configure_security.sh` | Apply security hardening | `sudo ./configure_security.sh` |
| `setup_monitoring.sh` | Configure monitoring integration | `sudo ./setup_monitoring.sh` |

### Running the Setup Scripts

#### Prerequisites
1. Fresh Raspberry Pi OS Lite installation
2. SSH access enabled
3. Internet connectivity
4. sudo privileges

#### Primary Pi Setup
```bash
cd /home/pi/pi-wifi-bridge

# Run primary setup (will prompt for WiFi credentials)
sudo ./setup_primary.sh

# Expected prompts:
# - WiFi SSID
# - WiFi Password  
# - Monitoring server IP (default: 10.0.0.40)
# - Admin email for notifications

# The script will:
# - Configure static IP (192.168.100.10)
# - Set up keepalived as MASTER
# - Install all monitoring scripts
# - Configure security rules
# - Set up cron jobs
```

#### Secondary Pi Setup
```bash
cd /home/pi/pi-wifi-bridge

# Run secondary setup (will prompt for WiFi credentials)
sudo ./setup_secondary.sh

# Expected prompts:
# - WiFi SSID (should match primary)
# - WiFi Password (should match primary)
# - Monitoring server IP (default: 10.0.0.40)
# - Admin email for notifications

# The script will:
# - Configure static IP (192.168.100.11)
# - Set up keepalived as BACKUP
# - Install all monitoring scripts
# - Configure security rules
# - Set up cron jobs
```

#### Post-Installation Script
```bash
# Install additional monitoring and health check scripts
sudo ./install_scripts.sh

# Configure advanced security (optional)
sudo ./configure_security.sh

# Set up monitoring integration (if using ELK stack)
sudo ./setup_monitoring.sh
```

### Script Execution Flow

```
1. setup_primary.sh / setup_secondary.sh
   ├── Update system packages
   ├── Install required software
   ├── Configure network interfaces
   ├── Set up WiFi credentials
   ├── Configure keepalived
   ├── Set up NAT/forwarding rules
   ├── Install health check scripts
   └── Configure cron jobs

2. install_scripts.sh
   ├── Create /home/pi/scripts directory
   ├── Install WiFi monitoring scripts
   ├── Install performance monitoring
   ├── Install failover event handlers
   ├── Set up system monitoring
   └── Configure log rotation

3. configure_security.sh
   ├── Harden SSH configuration
   ├── Configure advanced firewall rules
   ├── Set up intrusion detection
   ├── Configure fail2ban
   └── Apply security policies

4. setup_monitoring.sh
   ├── Configure ELK stack integration
   ├── Set up Grafana dashboards
   ├── Configure alert thresholds
   └── Test monitoring connectivity
```

---

Create the network configuration for each Pi:

**Primary Pi (192.168.100.10):**
```bash
sudo nano /etc/dhcpcd.conf
```

Add:
```
interface eth0
static ip_address=192.168.100.10/24
static routers=192.168.100.1
static domain_name_servers=192.168.100.1 8.8.8.8

interface wlan0
# Leave as DHCP client for WiFi connection
```

**Secondary Pi (192.168.100.11):**
```bash
sudo nano /etc/dhcpcd.conf
```

Add:
```
interface eth0
static ip_address=192.168.100.11/24
static routers=192.168.100.1
static domain_name_servers=192.168.100.1 8.8.8.8

interface wlan0
# DHCP client for WiFi
```

### 4. WiFi Configuration

Configure WiFi on both units:

```bash
sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
```

```
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="YourWiFiNetwork"
    psk="YourWiFiPassword"
    priority=10
    id_str="primary_wifi"
}

# For WPA Enterprise networks:
network={
    ssid="Enterprise-WiFi"
    key_mgmt=WPA-EAP
    eap=PEAP
    identity="username"
    password="password"
    phase2="auth=MSCHAPV2"
    priority=5
    id_str="enterprise_wifi"
}

# For guest networks (backup):
network={
    ssid="Guest-WiFi"
    psk="guest-password"
    priority=1
    id_str="guest_wifi"
}
```

---

## 🌉 Bridge and NAT Configuration

### Enable IP Forwarding and NAT

On both units:

```bash
# Enable IP forwarding permanently
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.conf.all.send_redirects=0' | sudo tee -a /etc/sysctl.conf

# Apply immediately
sudo sysctl -p

# Configure iptables for NAT
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Additional security rules
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -i eth0 -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -j DROP

# Save iptables rules
sudo netfilter-persistent save
sudo systemctl enable netfilter-persistent
```

### Network Optimization

Add to `/etc/sysctl.conf`:

```
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 65536 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.route.flush = 1
```

---

## 🔄 High Availability Configuration

### Network Configuration Table

| Role | IP Address | Priority | VRRP State | Router ID |
|------|------------|----------|------------|-----------|
| Primary Pi | 192.168.100.10/24 | 110 | MASTER | RPi_PRIMARY |
| Secondary Pi | 192.168.100.11/24 | 100 | BACKUP | RPi_SECONDARY |
| Virtual IP | 192.168.100.100/24 | Shared | Failover | - |
| Gateway | 192.168.100.1 | pfSense | - | - |

### Keepalived Configuration

**Primary Pi:**
```bash
sudo nano /etc/keepalived/keepalived.conf
```

```
global_defs {
    router_id RPi_PRIMARY
    script_user root
    enable_script_security
    notification_email {
        admin@company.com
    }
    notification_email_from rpi-primary@lab.local
    smtp_server 127.0.0.1
    smtp_connect_timeout 30
}

vrrp_script chk_wifi_connection {
    script "/home/pi/scripts/check_wifi.sh"
    interval 5
    timeout 3
    weight -15
    fall 3
    rise 2
}

vrrp_script chk_internet_connectivity {
    script "/home/pi/scripts/check_internet.sh"
    interval 10
    timeout 5
    weight -10
    fall 2
    rise 1
}

vrrp_script chk_bridge_performance {
    script "/home/pi/scripts/check_performance.sh"
    interval 30
    timeout 10
    weight -5
    fall 2
    rise 1
}

vrrp_instance VI_WIFI_BRIDGE {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 110
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
    notify_master "/home/pi/scripts/become_master.sh"
    notify_backup "/home/pi/scripts/become_backup.sh"
    notify_fault "/home/pi/scripts/fault_handler.sh"
}
```

**Secondary Pi:**
Use the same configuration but change:
- `router_id RPi_SECONDARY`
- `state BACKUP`
- `priority 100`

---

## 📊 Monitoring and Health Checks

### Create Scripts Directory

```bash
mkdir -p /home/pi/scripts
```

### WiFi Health Check Script

Create `/home/pi/scripts/check_wifi.sh`:

```bash
#!/bin/bash
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
if [ ! -z "$SIGNAL" ] && [ "$SIGNAL" -lt "-75" ]; then
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
```

### Internet Connectivity Check

Create `/home/pi/scripts/check_internet.sh`:

```bash
#!/bin/bash
LOG_FILE="/var/log/wifi_bridge.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

DNS_SERVERS=("8.8.8.8" "1.1.1.1" "208.67.222.222")
SUCCESS_COUNT=0

for dns in "${DNS_SERVERS[@]}"; do
    if ping -c 2 -W 3 $dns > /dev/null 2>&1; then
        ((SUCCESS_COUNT++))
    fi
done

if [ $SUCCESS_COUNT -eq 0 ]; then
    echo "[$TIMESTAMP] ERROR: No internet connectivity to any DNS server" >> $LOG_FILE
    exit 1
elif [ $SUCCESS_COUNT -eq 1 ]; then
    echo "[$TIMESTAMP] WARNING: Limited internet connectivity (1/${#DNS_SERVERS[@]} servers)" >> $LOG_FILE
    exit 0
else
    echo "[$TIMESTAMP] INFO: Internet connectivity OK (${SUCCESS_COUNT}/${#DNS_SERVERS[@]} servers)" >> $LOG_FILE
    exit 0
fi
```

### Performance Monitor

Create `/home/pi/scripts/check_performance.sh`:

```bash
#!/bin/bash
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
if [ "$ETH_ERRORS" -gt 100 ] || [ "$WIFI_ERRORS" -gt 100 ]; then
    echo "[$TIMESTAMP] WARNING: Network interface errors detected" >> $LOG_FILE
    exit 1
fi

echo "[$TIMESTAMP] INFO: Performance check OK - CPU: $CPU_LOAD, MEM: ${MEM_USAGE}%" >> $LOG_FILE
exit 0
```

### System Monitoring

Create `/home/pi/scripts/system_monitor.sh`:

```bash
#!/bin/bash
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
```

Make all scripts executable:
```bash
chmod +x /home/pi/scripts/*.sh
```

---

## 🔄 Failover Event Handlers

### Master Promotion Script

Create `/home/pi/scripts/become_master.sh`:

```bash
#!/bin/bash
LOG_FILE="/var/log/wifi_bridge.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] CRITICAL: Becoming MASTER bridge" >> $LOG_FILE

# Configure optimized settings for master role
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Increase network buffer sizes
sudo sysctl -w net.core.rmem_max=16777216
sudo sysctl -w net.core.wmem_max=16777216

# Send notification to monitoring system
curl -X POST http://10.0.0.40:9200/bridge-events/_doc \
-H 'Content-Type: application/json' \
-d "{
\"timestamp\": \"$(date -Iseconds)\",
\"event\": \"master_promotion\",
\"bridge_id\": \"$(hostname)\",
\"message\": \"Bridge promoted to master role\"
}" || true

echo "[$TIMESTAMP] INFO: Master role configuration complete" >> $LOG_FILE
```

### Backup Demotion Script

Create `/home/pi/scripts/become_backup.sh`:

```bash
#!/bin/bash
LOG_FILE="/var/log/wifi_bridge.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] INFO: Becoming BACKUP bridge" >> $LOG_FILE

# Configure power-saving settings for backup role
echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Send notification to monitoring system
curl -X POST http://10.0.0.40:9200/bridge-events/_doc \
-H 'Content-Type: application/json' \
-d "{
\"timestamp\": \"$(date -Iseconds)\",
\"event\": \"backup_demotion\",
\"bridge_id\": \"$(hostname)\",
\"message\": \"Bridge demoted to backup role\"
}" || true

echo "[$TIMESTAMP] INFO: Backup role configuration complete" >> $LOG_FILE
```

### Fault Handler Script

Create `/home/pi/scripts/fault_handler.sh`:

```bash
#!/bin/bash
LOG_FILE="/var/log/wifi_bridge.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] CRITICAL: Bridge fault detected" >> $LOG_FILE

# Attempt automatic recovery
echo "[$TIMESTAMP] INFO: Attempting automatic recovery..." >> $LOG_FILE

# Restart network interfaces
sudo systemctl restart dhcpcd
sleep 5

# Restart WiFi
sudo ifdown wlan0 && sudo ifup wlan0
sleep 10

# Check if recovery successful
if /home/pi/scripts/check_wifi.sh && /home/pi/scripts/check_internet.sh; then
    echo "[$TIMESTAMP] INFO: Automatic recovery successful" >> $LOG_FILE
    exit 0
else
    echo "[$TIMESTAMP] ERROR: Automatic recovery failed" >> $LOG_FILE
    
    # Send critical alert
    curl -X POST http://10.0.0.40:9200/bridge-alerts/_doc \
    -H 'Content-Type: application/json' \
    -d "{
    \"timestamp\": \"$(date -Iseconds)\",
    \"severity\": \"critical\",
    \"bridge_id\": \"$(hostname)\",
    \"message\": \"Bridge fault - automatic recovery failed\"
    }" || true
    
    exit 1
fi
```

---

## 🔒 Security Configuration

### SSH Hardening

Edit `/etc/ssh/sshd_config`:

```
Port 2222
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
AllowUsers pi
Protocol 2
```

Restart SSH:
```bash
sudo systemctl restart ssh
```

### Enhanced Firewall Rules

Create `/home/pi/scripts/security_rules.sh`:

```bash
#!/bin/bash

# Flush existing rules
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F

# Default policies
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Allow loopback
sudo iptables -A INPUT -i lo -j ACCEPT

# Allow established connections
sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow SSH from pfSense network only
sudo iptables -A INPUT -i eth0 -s 192.168.100.0/24 -p tcp --dport 2222 -j ACCEPT

# Allow VRRP traffic
sudo iptables -A INPUT -i eth0 -p vrrp -j ACCEPT
sudo iptables -A OUTPUT -o eth0 -p vrrp -j ACCEPT

# Allow ICMP (ping) for monitoring
sudo iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# NAT rules for bridging
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE

# Forward rules for bridge traffic
sudo iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

# Rate limiting for SSH
sudo iptables -A INPUT -p tcp --dport 2222 -m limit --limit 4/min --limit-burst 3 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 2222 -j DROP

# Log dropped packets
sudo iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "IPT-INPUT-DROP: "
sudo iptables -A FORWARD -m limit --limit 5/min -j LOG --log-prefix "IPT-FORWARD-DROP: "

# Save rules
sudo netfilter-persistent save

echo "Security rules applied successfully"
```

Apply security rules:
```bash
chmod +x /home/pi/scripts/security_rules.sh
/home/pi/scripts/security_rules.sh
```

---

## 📈 Advanced Features

### Traffic Shaping (QoS)

Install traffic control tools:
```bash
sudo apt install -y iproute2
```

Create `/home/pi/scripts/configure_qos.sh`:

```bash
#!/bin/bash

# Clear existing rules
sudo tc qdisc del dev eth0 root 2>/dev/null || true
sudo tc qdisc del dev wlan0 root 2>/dev/null || true

# Configure outbound traffic shaping (to WiFi)
sudo tc qdisc add dev wlan0 root handle 1: htb default 30

# High priority for management traffic (SSH, SNMP, monitoring)
sudo tc class add dev wlan0 parent 1: classid 1:10 htb rate 10mbit ceil 50mbit
sudo tc filter add dev wlan0 protocol ip parent 1:0 prio 1 u32 match ip dport 22 0xffff flowid 1:10
sudo tc filter add dev wlan0 protocol ip parent 1:0 prio 1 u32 match ip dport 161 0xffff flowid 1:10

# Medium priority for fuzzing traffic
sudo tc class add dev wlan0 parent 1: classid 1:20 htb rate 20mbit ceil 80mbit

# Lower priority for bulk traffic
sudo tc class add dev wlan0 parent 1: classid 1:30 htb rate 5mbit ceil 20mbit

echo "QoS configuration applied successfully"
```

### WiFi Auto-Selection

Create `/home/pi/scripts/wifi_auto_select.sh`:

```bash
#!/bin/bash
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
    
    # Parse scan results and find best known network
    while IFS= read -r line; do
        if [[ $line == *"ESSID"* ]]; then
            CURRENT_SSID=$(echo $line | cut -d'"' -f2)
        elif [[ $line == *"Signal level"* ]]; then
            CURRENT_SIGNAL=$(echo $line | awk '{print $3}' | cut -d'=' -f2)
            
            # Check if this is a known network
            for known in "${KNOWN_NETWORKS[@]}"; do
                ssid=${known%:*}
                priority=${known#*:}
                if [ "$CURRENT_SSID" = "$ssid" ]; then
                    # Calculate weighted score (signal + priority)
                    SCORE=$((CURRENT_SIGNAL + priority * 10))
                    BEST_SCORE=$((BEST_SIGNAL + BEST_PRIORITY * 10))
                    if [ $SCORE -gt $BEST_SCORE ]; then
                        BEST_NETWORK=$ssid
                        BEST_SIGNAL=$CURRENT_SIGNAL
                        BEST_PRIORITY=$priority
                    fi
                fi
            done
        fi
    done < /tmp/wifi_scan.txt
    
    if [ ! -z "$BEST_NETWORK" ]; then
        echo "[$TIMESTAMP] INFO: Best network found: $BEST_NETWORK (Signal: ${BEST_SIGNAL}dBm)" >> $LOG_FILE
        
        # Connect to best network
        sudo wpa_cli -i wlan0 select_network $(wpa_cli -i wlan0 list_networks | grep "$BEST_NETWORK" | cut -f1)
        sleep 10
        
        # Verify connection
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
if [ ! -z "$CURRENT_SIGNAL" ] && [ "$CURRENT_SIGNAL" -lt "-80" ]; then
    echo "[$TIMESTAMP] INFO: Current signal poor ($CURRENT_SIGNAL dBm), searching for better network..." >> $LOG_FILE
    select_best_wifi
fi
```

---

## 🔄 Automated Setup

### Complete Setup Script

The main setup script that handles both primary and secondary configuration:

Create `/home/pi/pi-wifi-bridge/setup_wifi_bridge.sh`:

```bash
#!/bin/bash
set -e

echo "=== Raspberry Pi WiFi Bridge Setup ==="

# Get configuration parameters
read -p "Is this the primary bridge? (y/n): " IS_PRIMARY
read -p "Enter WiFi SSID: " WIFI_SSID
read -s -p "Enter WiFi password: " WIFI_PASSWORD
echo
read -p "Enter ethernet IP (192.168.100.10 or 192.168.100.11): " ETH_IP

# Determine priority for keepalived
if [ "$IS_PRIMARY" = "y" ]; then
    PRIORITY=110
    STATE="MASTER"
    ROUTER_ID="RPi_PRIMARY"
else
    PRIORITY=100
    STATE="BACKUP"
    ROUTER_ID="RPi_SECONDARY"
fi

echo "Configuring as $STATE with priority $PRIORITY..."

# Configure network interfaces
sudo tee /etc/dhcpcd.conf > /dev/null << DHCP_EOF
interface eth0
static ip_address=${ETH_IP}/24
static routers=192.168.100.1
static domain_name_servers=192.168.100.1 8.8.8.8

interface wlan0
# DHCP client for WiFi connection
DHCP_EOF

# Configure WiFi
sudo tee /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null << WIFI_EOF
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="$WIFI_SSID"
    psk="$WIFI_PASSWORD"
    priority=10
    id_str="primary_wifi"
}
WIFI_EOF

# Apply network settings
echo "Applying network configuration..."
sudo systemctl restart dhcpcd
sudo systemctl restart wpa_supplicant

echo "Setup complete! Please reboot and verify configuration."
```

---

## ✅ Verification and Testing

### Using Setup Scripts

If you used the automated setup scripts, run the built-in verification:

```bash
# Run verification script
cd /home/pi/pi-wifi-bridge
./verify_setup.sh

# Check specific components
./scripts/check_wifi.sh
./scripts/check_internet.sh  
./scripts/check_performance.sh
```

### Manual Verification

### Check Network Configuration
```bash
# Check ethernet interface
ip addr show eth0

# Check WiFi status
iwconfig wlan0

# Check WiFi connection
ping -c 4 8.8.8.8
```

### Check keepalived Status
```bash
sudo systemctl status keepalived
```

### Monitor Logs
```bash
# WiFi bridge logs
tail -f /var/log/wifi_bridge.log

# System stats
tail -f /var/log/system_stats.log

# Keepalived logs
sudo journalctl -u keepalived -f
```

### Verify Failover
1. Check current master: `ip addr show | grep 192.168.100.100`
2. Disconnect primary Pi from power or network
3. Verify secondary Pi takes over the virtual IP
4. Check logs and keepalived status to confirm failover

---

## ⚙️ Maintenance and Automation

### Cron Jobs Setup

Add monitoring jobs to crontab:

```bash
(crontab -l 2>/dev/null; echo "*/5 * * * * /home/pi/scripts/system_monitor.sh") | crontab -
(crontab -l 2>/dev/null; echo "*/15 * * * * /home/pi/scripts/wifi_auto_select.sh") | crontab -
```

### Log Rotation

Configure log rotation:

```bash
sudo nano /etc/logrotate.d/wifi-bridge
```

```
/var/log/wifi_bridge.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    create 0644 pi pi
    postrotate
        systemctl reload rsyslog > /dev/null 2>&1 || true
    endscript
}

/var/log/system_stats.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    create 0644 pi pi
}
```

---

## 📊 Monitoring Integration

### ELK Stack Integration
- Metrics and logs are sent to ELK stack at `http://10.0.0.40:9200`
- Events are logged to indices: `bridge-events`, `bridge-metrics`, `bridge-alerts`

### Health Check Schedule
- WiFi connection check: Every 5 seconds
- Internet connectivity: Every 10 seconds  
- Performance monitoring: Every 30 seconds
- System stats collection: Every 5 minutes
- WiFi auto-selection: Every 15 minutes

---

## 🛡️ Security Features

### Implemented Security Measures
- SSH access limited to pfSense subnet (192.168.100.0/24)
- Custom SSH port (2222) with rate limiting
- VRRP traffic allowed for failover
- NAT and forwarding rules for bridge functionality
- Comprehensive logging of dropped packets
- Firewall rules with state tracking

### Security Best Practices
- Regular security updates
- Strong password policies
- Network segmentation
- Access logging and monitoring
- Intrusion detection and prevention

---

## 🚨 Troubleshooting

### Setup Script Troubleshooting

#### Common Script Issues

| Issue | Solution | Command |
|-------|----------|---------|
| Script not found | Check file path and download | `ls -la /home/pi/pi-wifi-bridge/` |
| Permission denied | Make executable | `chmod +x *.sh` |
| Network configuration fails | Run manually | `sudo dhcpcd` |
| WiFi connection fails | Check credentials | `sudo wpa_cli status` |
| keepalived won't start | Check config syntax | `sudo keepalived -t` |

#### Script Execution Logs

The setup scripts create detailed logs:

```bash
# View setup logs
tail -f /var/log/setup.log

# View script-specific logs  
tail -f /var/log/wifi_bridge_setup.log

# Check for script errors
grep ERROR /var/log/setup.log
```

#### Re-running Scripts

If a script fails partway through:

```bash
# Clean up partial installation
sudo ./cleanup.sh

# Re-run setup
sudo ./setup_primary.sh --force

# Skip completed steps
sudo ./setup_primary.sh --resume
```

### Manual Troubleshooting

#### WiFi Connection Problems
```bash
# Check WiFi interface status
sudo iwconfig wlan0

# Restart WiFi service
sudo systemctl restart wpa_supplicant

# Manual WiFi connection
sudo wpa_cli -i wlan0 reconfigure

# Check WiFi logs
sudo journalctl -u wpa_supplicant
```

#### keepalived Issues
```bash
# Check keepalived status
sudo systemctl status keepalived

# View keepalived logs
sudo journalctl -u keepalived -n 50

# Restart keepalived
sudo systemctl restart keepalived

# Check VRRP traffic
sudo tcpdump -i eth0 proto 112
```

#### Network Performance Issues
```bash
# Check network statistics
cat /proc/net/dev

# Monitor network traffic
sudo iftop -i wlan0

# Test bandwidth
iperf3 -c [target-server]

# Check for packet loss
ping -c 100 8.8.8.8 | grep loss
```

#### High CPU/Memory Usage
```bash
# Check top processes
htop

# Monitor CPU temperature
vcgencmd measure_temp

# Check memory usage
free -h

# Check disk usage
df -h
```

### Diagnostic Commands

| Issue | Command | Expected Result |
|-------|---------|-----------------|
| WiFi Status | `iwconfig wlan0` | Shows connected SSID and signal |
| IP Assignment | `ip addr show` | Shows IP on both interfaces |
| Routing | `ip route show` | Shows default route via WiFi |
| NAT Rules | `sudo iptables -t nat -L` | Shows MASQUERADE rule |
| keepalived Status | `sudo systemctl status keepalived` | Active (running) |
| Virtual IP | `ip addr show \| grep 192.168.100.100` | Present on master |

---

## 📋 Setup Script Reference

### Script Parameters

#### setup_primary.sh
```bash
./setup_primary.sh [OPTIONS]

Options:
  --wifi-ssid SSID       WiFi network name
  --wifi-pass PASSWORD   WiFi password  
  --monitor-ip IP        Monitoring server IP (default: 10.0.0.40)
  --admin-email EMAIL    Admin email for alerts
  --force               Force overwrite existing config
  --resume              Resume from failed step
  --help                Show help message

Example:
./setup_primary.sh --wifi-ssid "MyWiFi" --wifi-pass "password123" --monitor-ip "192.168.1.100"
```

#### setup_secondary.sh  
```bash
./setup_secondary.sh [OPTIONS]

Options: (Same as primary)
  --wifi-ssid SSID       WiFi network name (should match primary)
  --wifi-pass PASSWORD   WiFi password (should match primary)
  --monitor-ip IP        Monitoring server IP (default: 10.0.0.40)
  --admin-email EMAIL    Admin email for alerts
  --force               Force overwrite existing config  
  --resume              Resume from failed step
  --help                Show help message
```

### Configuration Files Created by Scripts

The setup scripts automatically create all necessary configuration files:

| File | Script | Purpose |
|------|--------|---------|
| `/etc/dhcpcd.conf` | setup_*.sh | Static IP configuration |
| `/etc/wpa_supplicant/wpa_supplicant.conf` | setup_*.sh | WiFi credentials |
| `/etc/keepalived/keepalived.conf` | setup_*.sh | HA configuration |  
| `/home/pi/scripts/*.sh` | install_scripts.sh | Monitoring scripts |
| `/etc/iptables/rules.v4` | configure_security.sh | Firewall rules |
| `/etc/crontab` entries | setup_*.sh | Scheduled tasks |

---

### Daily Checks
- [ ] Verify both Pi units are online and responsive
- [ ] Check WiFi signal strength on both units
- [ ] Review logs for errors or warnings
- [ ] Confirm virtual IP is active on current master

### Weekly Maintenance
- [ ] Test failover by disconnecting primary Pi
- [ ] Review system performance metrics
- [ ] Check disk space usage
- [ ] Update system packages if needed
- [ ] Verify backup Pi can become master

### Monthly Tasks (Script-Assisted)
- [ ] Full system backup of configurations (`./scripts/backup_config.sh`)
- [ ] Review and rotate logs (`./scripts/rotate_logs.sh`)
- [ ] Test all monitoring scripts (`./scripts/test_all_monitoring.sh`)
- [ ] Update WiFi credentials if changed (`./scripts/update_wifi.sh`)
- [ ] Performance baseline comparison (`./scripts/baseline_performance.sh`)

---

## 🔧 Configuration Files Reference

### Key Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| Network Config | Static IP settings | `/etc/dhcpcd.conf` |
| WiFi Config | WiFi credentials | `/etc/wpa_supplicant/wpa_supplicant.conf` |
| keepalived Config | HA configuration | `/etc/keepalived/keepalived.conf` |
| System Optimization | Kernel parameters | `/etc/sysctl.conf` |
| SSH Config | SSH hardening | `/etc/ssh/sshd_config` |
| Log Rotation | Log management | `/etc/logrotate.d/wifi-bridge` |

### Important Log Files

| Log File | Content | Retention |
|----------|---------|-----------|
| `/var/log/wifi_bridge.log` | Bridge operations | 30 days |
| `/var/log/system_stats.log` | Performance metrics | 7 days |
| `/var/log/syslog` | System messages | Default |
| `/var/log/auth.log` | Authentication logs | Default |

---

## 🚀 Performance Optimization

### Network Optimization Settings

Applied via `/etc/sysctl.conf`:

```
# TCP Buffer sizes
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 65536 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# Network queue settings
net.core.netdev_max_backlog = 5000
net.core.netdev_budget = 600

# TCP optimizations
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_congestion_control = bbr
```

### Hardware Optimization

```bash
# CPU governor settings (master)
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# CPU governor settings (backup)
echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# GPU memory split (reduce for headless)
echo "gpu_mem=16" | sudo tee -a /boot/config.txt
```

---

## 📚 Additional Resources

### Documentation
- [Raspberry Pi Official Documentation](https://www.raspberrypi.org/documentation/)
- [keepalived Documentation](https://keepalived.readthedocs.io/)
- [iptables Tutorial](https://netfilter.org/documentation/)

### Monitoring Tools
- ELK Stack for centralized logging
- Prometheus + Grafana for metrics
- Nagios or Zabbix for alerting
- Custom scripts for health checks

### Support Channels
- Check system logs first: `/var/log/wifi_bridge.log`
- Use built-in diagnostic scripts
- Monitor ELK stack dashboards
- Review keepalived status and logs

---

## 🏁 Final Steps

### Post-Installation Verification

1. **Network Connectivity Test**
   ```bash
   # From pfSense network, test connectivity through bridge
   ping -c 4 8.8.8.8
   traceroute 8.8.8.8
   ```

2. **Failover Test**
   ```bash
   # Disconnect primary Pi and verify secondary takes over
   # Check virtual IP migration
   ip addr show | grep 192.168.100.100
   ```

3. **Performance Baseline**
   ```bash
   # Establish baseline performance metrics
   /home/pi/scripts/system_monitor.sh
   iperf3 -c [internet-server] -t 60
   ```

4. **Monitoring Setup**
   ```bash
   # Verify monitoring data is being sent to ELK
   curl http://10.0.0.40:9200/bridge-metrics/_search?pretty
   ```

### Final Configuration Summary

Your WiFi bridge setup includes:

- ✅ **High Availability**: Automatic failover with keepalived
- ✅ **Health Monitoring**: Comprehensive health checks and alerting  
- ✅ **Security**: Hardened SSH, firewall rules, and access controls
- ✅ **Performance**: Optimized network settings and QoS
- ✅ **Automation**: Automated recovery and network selection
- ✅ **Monitoring**: Integration with ELK stack for metrics and logs
- ✅ **Maintenance**: Automated log rotation and system monitoring

The bridges are now ready for production use in your ICS Fuzzing Lab environment.

---

## 📞 Support and Maintenance

### Regular Maintenance Schedule
- **Real-time**: Automated health checks and recovery
- **Hourly**: Performance monitoring and alerting
- **Daily**: Log review and system health assessment
- **Weekly**: Failover testing and performance analysis
- **Monthly**: System updates and configuration backup

### Emergency Procedures
1. **Primary Bridge Failure**: Secondary automatically takes over
2. **Both Bridges Down**: Check network infrastructure and power
3. **WiFi Network Issues**: Bridges will attempt auto-recovery
4. **Performance Degradation**: Automatic alerts sent to monitoring system

---

*This guide provides a complete, production-ready WiFi bridge solution with enterprise-grade reliability, monitoring, and security features.*
