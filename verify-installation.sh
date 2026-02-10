#!/bin/bash

# VPN Installation Verification Script
# Checks if VPN services are properly configured and running

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}VPN Installation Verification${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Function to check service status
check_service() {
    local service=$1
    local name=$2
    
    if systemctl is-active --quiet $service; then
        echo -e "${GREEN}✓${NC} $name is running"
        return 0
    else
        echo -e "${RED}✗${NC} $name is not running"
        return 1
    fi
}

# Function to check port
check_port() {
    local port=$1
    local protocol=$2
    local name=$3
    
    if sudo netstat -tulpn | grep -q ":$port.*$protocol"; then
        echo -e "${GREEN}✓${NC} $name port $port/$protocol is open"
        return 0
    else
        echo -e "${RED}✗${NC} $name port $port/$protocol is not open"
        return 1
    fi
}

# Function to check file exists
check_file() {
    local file=$1
    local name=$2
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $name exists: $file"
        return 0
    else
        echo -e "${RED}✗${NC} $name not found: $file"
        return 1
    fi
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}" 
   exit 1
fi

# Install netstat if not present
if ! command -v netstat &> /dev/null; then
    echo -e "${YELLOW}Installing net-tools...${NC}"
    apt-get update && apt-get install -y net-tools
fi

echo -e "${YELLOW}Checking WireGuard...${NC}"
WIREGUARD_OK=true
if check_service "wg-quick@wg0" "WireGuard"; then
    check_port "51820" "udp" "WireGuard" || WIREGUARD_OK=false
    check_file "/etc/wireguard/wg0.conf" "WireGuard config" || WIREGUARD_OK=false
    check_file "/etc/wireguard/server_private.key" "WireGuard server key" || WIREGUARD_OK=false
    
    if [ -d "/root/wireguard-clients" ]; then
        CLIENT_COUNT=$(ls -1 /root/wireguard-clients/*.conf 2>/dev/null | wc -l)
        echo -e "${GREEN}✓${NC} Found $CLIENT_COUNT client configuration(s)"
    fi
    
    # Check IP forwarding
    if [ "$(cat /proc/sys/net/ipv4/ip_forward)" = "1" ]; then
        echo -e "${GREEN}✓${NC} IP forwarding is enabled"
    else
        echo -e "${RED}✗${NC} IP forwarding is disabled"
        WIREGUARD_OK=false
    fi
else
    WIREGUARD_OK=false
    echo -e "${YELLOW}WireGuard is not installed or not running${NC}"
fi
echo ""

echo -e "${YELLOW}Checking Shadowsocks...${NC}"
SHADOWSOCKS_OK=true
if check_service "shadowsocks" "Shadowsocks"; then
    check_port "8388" "tcp" "Shadowsocks" || SHADOWSOCKS_OK=false
    check_file "/etc/shadowsocks/config.json" "Shadowsocks config" || SHADOWSOCKS_OK=false
    
    if [ -d "/root/shadowsocks-clients" ]; then
        echo -e "${GREEN}✓${NC} Client configurations available in /root/shadowsocks-clients/"
    fi
else
    SHADOWSOCKS_OK=false
    echo -e "${YELLOW}Shadowsocks is not installed or not running${NC}"
fi
echo ""

echo -e "${YELLOW}Checking OpenVPN...${NC}"
OPENVPN_OK=true
if check_service "openvpn@server" "OpenVPN"; then
    check_port "1194" "udp" "OpenVPN" || OPENVPN_OK=false
    check_file "/etc/openvpn/server.conf" "OpenVPN config" || OPENVPN_OK=false
    check_file "/etc/openvpn/ca.crt" "OpenVPN CA certificate" || OPENVPN_OK=false
    
    if [ -d "/root/openvpn-clients" ]; then
        CLIENT_COUNT=$(ls -1 /root/openvpn-clients/*.ovpn 2>/dev/null | wc -l)
        echo -e "${GREEN}✓${NC} Found $CLIENT_COUNT client configuration(s)"
    fi
else
    OPENVPN_OK=false
    echo -e "${YELLOW}OpenVPN is not installed or not running${NC}"
fi
echo ""

# Check firewall
echo -e "${YELLOW}Checking Firewall...${NC}"
if command -v ufw &> /dev/null; then
    if sudo ufw status | grep -q "Status: active"; then
        echo -e "${GREEN}✓${NC} UFW firewall is active"
        
        # Check if VPN ports are allowed
        if sudo ufw status | grep -q "51820/udp"; then
            echo -e "${GREEN}✓${NC} WireGuard port allowed in firewall"
        fi
        if sudo ufw status | grep -q "8388"; then
            echo -e "${GREEN}✓${NC} Shadowsocks port allowed in firewall"
        fi
        if sudo ufw status | grep -q "1194/udp"; then
            echo -e "${GREEN}✓${NC} OpenVPN port allowed in firewall"
        fi
    else
        echo -e "${YELLOW}⚠${NC} UFW firewall is not active"
    fi
elif command -v firewall-cmd &> /dev/null; then
    if sudo firewall-cmd --state | grep -q "running"; then
        echo -e "${GREEN}✓${NC} Firewalld is active"
    else
        echo -e "${YELLOW}⚠${NC} Firewalld is not running"
    fi
else
    echo -e "${YELLOW}⚠${NC} No firewall detected (UFW or Firewalld)"
fi
echo ""

# Get server IP
echo -e "${YELLOW}Server Information:${NC}"
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d/ -f1 | head -n1)
echo -e "Public IP: ${GREEN}$SERVER_IP${NC}"
echo ""

# Network connectivity test
echo -e "${YELLOW}Testing Network Connectivity...${NC}"
if ping -c 1 8.8.8.8 &> /dev/null; then
    echo -e "${GREEN}✓${NC} Internet connectivity working"
else
    echo -e "${RED}✗${NC} No internet connectivity"
fi

if ping -c 1 1.1.1.1 &> /dev/null; then
    echo -e "${GREEN}✓${NC} DNS resolution working"
else
    echo -e "${RED}✗${NC} DNS resolution issues"
fi
echo ""

# Summary
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Verification Summary${NC}"
echo -e "${BLUE}================================${NC}"

TOTAL_OK=0
TOTAL_SERVICES=0

if [ "$WIREGUARD_OK" = true ]; then
    echo -e "${GREEN}✓ WireGuard: WORKING${NC}"
    TOTAL_OK=$((TOTAL_OK + 1))
    TOTAL_SERVICES=$((TOTAL_SERVICES + 1))
elif systemctl list-unit-files | grep -q "wg-quick@wg0"; then
    echo -e "${RED}✗ WireGuard: INSTALLED BUT NOT WORKING${NC}"
    TOTAL_SERVICES=$((TOTAL_SERVICES + 1))
fi

if [ "$SHADOWSOCKS_OK" = true ]; then
    echo -e "${GREEN}✓ Shadowsocks: WORKING${NC}"
    TOTAL_OK=$((TOTAL_OK + 1))
    TOTAL_SERVICES=$((TOTAL_SERVICES + 1))
elif systemctl list-unit-files | grep -q "shadowsocks"; then
    echo -e "${RED}✗ Shadowsocks: INSTALLED BUT NOT WORKING${NC}"
    TOTAL_SERVICES=$((TOTAL_SERVICES + 1))
fi

if [ "$OPENVPN_OK" = true ]; then
    echo -e "${GREEN}✓ OpenVPN: WORKING${NC}"
    TOTAL_OK=$((TOTAL_OK + 1))
    TOTAL_SERVICES=$((TOTAL_SERVICES + 1))
elif systemctl list-unit-files | grep -q "openvpn@server"; then
    echo -e "${RED}✗ OpenVPN: INSTALLED BUT NOT WORKING${NC}"
    TOTAL_SERVICES=$((TOTAL_SERVICES + 1))
fi

echo ""
if [ $TOTAL_SERVICES -eq 0 ]; then
    echo -e "${RED}No VPN services found. Please run setup scripts first.${NC}"
elif [ $TOTAL_OK -eq $TOTAL_SERVICES ]; then
    echo -e "${GREEN}All installed VPN services are working correctly! ✓${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "1. Download client configurations from /root/*/clients/"
    echo -e "2. Install VPN client on your device"
    echo -e "3. Import configuration and connect"
    echo -e "4. Test connection at: https://ipleak.net"
else
    echo -e "${YELLOW}Some services need attention. Check the errors above.${NC}"
    echo ""
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo -e "1. Check service logs: sudo journalctl -u SERVICE_NAME -n 50"
    echo -e "2. Restart services: sudo systemctl restart SERVICE_NAME"
    echo -e "3. Check firewall: sudo ufw status"
    echo -e "4. Verify ports: sudo netstat -tulpn"
fi

echo ""
echo -e "${BLUE}================================${NC}"

# Detailed logs option
echo ""
read -p "Show detailed service logs? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if systemctl is-active --quiet wg-quick@wg0; then
        echo -e "${YELLOW}WireGuard logs:${NC}"
        sudo journalctl -u wg-quick@wg0 -n 20 --no-pager
        echo ""
    fi
    
    if systemctl is-active --quiet shadowsocks; then
        echo -e "${YELLOW}Shadowsocks logs:${NC}"
        sudo journalctl -u shadowsocks -n 20 --no-pager
        echo ""
    fi
    
    if systemctl is-active --quiet openvpn@server; then
        echo -e "${YELLOW}OpenVPN logs:${NC}"
        sudo journalctl -u openvpn@server -n 20 --no-pager
        echo ""
    fi
fi
