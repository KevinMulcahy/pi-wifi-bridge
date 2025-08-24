#!/bin/bash
# QoS Traffic Shaping Configuration
# Implements priority-based traffic management

# Clear existing rules
sudo tc qdisc del dev eth0 root 2>/dev/null || true
sudo tc qdisc del dev wlan0 root 2>/dev/null || true

# Configure outbound traffic shaping (to WiFi)
sudo tc qdisc add dev wlan0 root handle 1: htb default 30

# High priority for management traffic (SSH, SNMP, monitoring)
sudo tc class add dev wlan0 parent 1: classid 1:10 htb rate 10mbit ceil 50mbit
sudo tc filter add dev wlan0 protocol ip parent 1:0 prio 1 u32 match ip dport 22 0xffff flowid 1:10
sudo tc filter add dev wlan0 protocol ip parent 1:0 prio 1 u32 match ip dport 2222 0xffff flowid 1:10
sudo tc filter add dev wlan0 protocol ip parent 1:0 prio 1 u32 match ip dport 161 0xffff flowid 1:10

# Medium priority for fuzzing traffic
sudo tc class add dev wlan0 parent 1: classid 1:20 htb rate 20mbit ceil 80mbit

# Lower priority for bulk traffic
sudo tc class add dev wlan0 parent 1: classid 1:30 htb rate 5mbit ceil 20mbit

echo "QoS configuration applied successfully"