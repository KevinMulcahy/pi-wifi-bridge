#!/bin/bash
# Security Rules Script
# Applies comprehensive iptables firewall rules

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