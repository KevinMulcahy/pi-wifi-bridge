#!/bin/bash
# Network Diagnostics Script
# Comprehensive network troubleshooting information

echo "=== WiFi Bridge Network Diagnostics ==="

echo "## Interface Status"
ip link show eth0
ip link show wlan0
echo ""

echo "## IP Configuration"
ip addr show eth0
ip addr show wlan0
echo ""

echo "## WiFi Details"
iwconfig wlan0
echo ""

echo "## Route Table"
ip route show
echo ""

echo "## ARP Table"
arp -a
echo ""

echo "## Active Connections"
ss -tuln
echo ""

echo "## iptables Rules"
sudo iptables -L -n -v
echo ""

echo "## NAT Rules"
sudo iptables -t nat -L -n -v
echo ""

echo "## System Load"
uptime
free -h
df -h
echo ""

echo "## Recent Network Errors"
dmesg | grep -i "network\|wifi\|eth0\|wlan0" | tail -10
echo ""

echo "## WiFi Scan Results"
sudo iwlist wlan0 scan | grep -E "(ESSID|Signal level|Encryption)" | head -20