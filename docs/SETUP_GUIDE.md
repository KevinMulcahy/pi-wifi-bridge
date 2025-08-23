# Raspberry Pi WiFi Bridge Setup Guide

This guide walks you through the complete setup of a high-availability WiFi-to-Ethernet bridge using two Raspberry Pi 3B+ units.

---

## 📦 Requirements

### Hardware
- 2x Raspberry Pi 3 B+
- 2x MicroSD cards (32GB+ Class 10)
- Ethernet cables
- Reliable power supplies

### Software
- Raspberry Pi OS Lite
- keepalived
- iptables-persistent

---

## 🛠️ Installation Steps

### 1. Flash Raspberry Pi OS Lite
Use Raspberry Pi Imager or Balena Etcher to flash Raspberry Pi OS Lite onto both microSD cards.

### 2. Clone the Repository
On both Raspberry Pi units:

cd /home/pi
git clone https://github.com/KevinMulcahy/pi-wifi-bridge.git
cd pi-wifi-bridge
3. Run Setup Scripts
On the primary Pi:


On the secondary Pi:


## Network Configuration

| Role | IP Address | Priority | VRRP State |
|------|------------|----------|------------|
| Primary Pi | 192.168.100.10/24 | 110 | MASTER |
| Secondary Pi | 192.168.100.11/24 | 100 | BACKUP |
| Virtual IP | 192.168.100.100/24 | Shared | Failover |
| Gateway | 192.168.100.1 | pfSense | |

# 🔍 Verification

## Check WiFi

```shell
iwconfig wlan0
```

## Check Keepalived

```shell
sudo systemctl status keepalived
```

## Monitor Logs

```shell
tail -f /var/log/wifi_bridge.log
```
---

# 🔧 Failover Testing

1. Disconnect the primary Pi from power or network.
2. Observe the secondary Pi taking over the virtual IP.
3. Check logs and keepalived status to confirm failover.

---

# 📊 Monitoring Integration

- Metrics and logs are sent to an ELK stack at http://10.0.0.40:9200.

---

# 🛡️ Security

Firewall rules are applied via scripts/security_rules.sh and include:

- SSH access limited to pfSense subnet
- VRRP traffic allowed
- NAT and forwarding rules
- Rate limiting and logging

---

# 📦 Maintenance

- Daily health checks via cron
- System monitoring every 5 minutes
- WiFi auto-selection every 15 minutes

---

# 📬 Support

- Use the GitHub issue tracker for questions or bug reports.

