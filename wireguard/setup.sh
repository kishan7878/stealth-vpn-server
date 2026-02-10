#!/bin/bash

# WireGuard VPN Server Setup Script
# Supports Ubuntu 20.04+, Debian 10+, CentOS 8+

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}WireGuard VPN Server Setup${NC}"
echo -e "${GREEN}================================${NC}"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}" 
   exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${RED}Cannot detect OS${NC}"
    exit 1
fi

# Install WireGuard
echo -e "${YELLOW}Installing WireGuard...${NC}"
case $OS in
    ubuntu|debian)
        apt update
        apt install -y wireguard qrencode iptables
        ;;
    centos|rhel|fedora)
        yum install -y epel-release
        yum install -y wireguard-tools qrencode iptables
        ;;
    *)
        echo -e "${RED}Unsupported OS${NC}"
        exit 1
        ;;
esac

# Generate server keys
echo -e "${YELLOW}Generating server keys...${NC}"
cd /etc/wireguard
umask 077
wg genkey | tee server_private.key | wg pubkey > server_public.key

SERVER_PRIVATE_KEY=$(cat server_private.key)
SERVER_PUBLIC_KEY=$(cat server_public.key)

# Get server IP
SERVER_IP=$(curl -s ifconfig.me)
if [ -z "$SERVER_IP" ]; then
    SERVER_IP=$(ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d/ -f1 | head -n1)
fi

# Get network interface
NET_INTERFACE=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)

# Create server configuration
echo -e "${YELLOW}Creating server configuration...${NC}"
cat > /etc/wireguard/wg0.conf << EOF
[Interface]
Address = 10.8.0.1/24
ListenPort = 51820
PrivateKey = $SERVER_PRIVATE_KEY
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $NET_INTERFACE -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $NET_INTERFACE -j MASQUERADE
SaveConfig = false
EOF

# Enable IP forwarding
echo -e "${YELLOW}Enabling IP forwarding...${NC}"
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Configure firewall
echo -e "${YELLOW}Configuring firewall...${NC}"
if command -v ufw &> /dev/null; then
    ufw allow 51820/udp
    ufw --force enable
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=51820/udp
    firewall-cmd --reload
fi

# Start WireGuard
echo -e "${YELLOW}Starting WireGuard...${NC}"
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

# Generate client configuration
echo -e "${YELLOW}Generating client configuration...${NC}"
CLIENT_PRIVATE_KEY=$(wg genkey)
CLIENT_PUBLIC_KEY=$(echo $CLIENT_PRIVATE_KEY | wg pubkey)
CLIENT_PRESHARED_KEY=$(wg genpsk)

# Add client to server config
cat >> /etc/wireguard/wg0.conf << EOF

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
PresharedKey = $CLIENT_PRESHARED_KEY
AllowedIPs = 10.8.0.2/32
EOF

# Restart WireGuard to apply changes
systemctl restart wg-quick@wg0

# Create client config file
mkdir -p /root/wireguard-clients
cat > /root/wireguard-clients/client1.conf << EOF
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = 10.8.0.2/32
DNS = 1.1.1.1, 8.8.8.8

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
PresharedKey = $CLIENT_PRESHARED_KEY
Endpoint = $SERVER_IP:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

# Generate QR code for mobile devices
echo -e "${YELLOW}Generating QR code for mobile devices...${NC}"
qrencode -t ansiutf8 < /root/wireguard-clients/client1.conf

# Save QR code to file
qrencode -t png -o /root/wireguard-clients/client1-qr.png < /root/wireguard-clients/client1.conf

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}WireGuard Setup Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${YELLOW}Server Information:${NC}"
echo -e "Server IP: ${GREEN}$SERVER_IP${NC}"
echo -e "Server Port: ${GREEN}51820${NC}"
echo -e "Server Public Key: ${GREEN}$SERVER_PUBLIC_KEY${NC}"
echo ""
echo -e "${YELLOW}Client Configuration:${NC}"
echo -e "Location: ${GREEN}/root/wireguard-clients/client1.conf${NC}"
echo -e "QR Code: ${GREEN}/root/wireguard-clients/client1-qr.png${NC}"
echo ""
echo -e "${YELLOW}To add more clients, run:${NC}"
echo -e "${GREEN}./add-client.sh <client-name>${NC}"
echo ""
echo -e "${YELLOW}Client Configuration File:${NC}"
cat /root/wireguard-clients/client1.conf
echo ""
echo -e "${YELLOW}Scan this QR code with your mobile device:${NC}"
qrencode -t ansiutf8 < /root/wireguard-clients/client1.conf
echo ""
echo -e "${GREEN}Setup completed successfully!${NC}"
