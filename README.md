# Raspberry Pi WiFi Bridge
A high-availability WiFi-to-Ethernet bridge solution using two Raspberry Pi 3B+ units with automatic failover.

## Features
- **High Availability**: Redundant bridge configuration with automatic failover
- **Health Monitoring**: Comprehensive connectivity and performance monitoring
- **Security Hardened**: Firewall rules and SSH hardening included
- **Performance Optimized**: QoS traffic shaping and network optimizations
- **Automated Setup**: Complete installation and configuration scripts
- **Monitoring Integration**: ELK stack integration for centralized logging

## Quick Start
1. Flash Raspberry Pi OS Lite on two microSD cards
2. Clone this repository to `/home/pi/` on both Pi units
3. Run setup on primary Pi:
    ```bash
    sudo ./setup.sh
    ```
4. Run setup on secondary Pi:
    ```bash
    sudo ./setup_secondary.sh
    ```
5. Verify keepalived status:
    ```bash
    sudo systemctl status keepalived
    ```

## Network Configuration
- **Primary Pi**: `192.168.100.10/24` (MASTER, Priority 110)
- **Secondary Pi**: `192.168.100.11/24` (BACKUP, Priority 100)
- **Virtual IP**: `192.168.100.100/24` (Shared failover IP)
- **Gateway**: `192.168.100.1` (pfSense)

## Documentation
See docs/SETUP_GUIDE.md for complete setup instructions and configuration details.

## Requirements
### Hardware
- 2x Raspberry Pi 3 B+
- 2x MicroSD cards (32GB+ Class 10)
- Ethernet cables
- Reliable power supplies

### Software
- Raspberry Pi OS Lite
- keepalived
- iptables-persistent

## License
MIT License – see LICENSE file for details.

## Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Support
For issues and questions, please use the GitHub issue tracker.