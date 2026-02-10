#!/bin/bash

# WireGuard Add Client Script

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}" 
   exit 1
fi

if [ -z "$1" ]; then
    echo -e "${RED}Usage: $0 <client-name>${NC}"
    exit 1
fi

CLIENT_NAME=$1
SERVER_PUBLIC_KEY=$(cat /etc/wireguard/server_public.key)
SERVER_IP=$(curl -s ifconfig.me)

# Get next available IP
LAST_IP=$(grep "AllowedIPs" /etc/wireguard/wg0.conf | tail -1 | awk '{print $3}' | cut -d'/' -f1 | cut -d'.' -f4)
if [ -z "$LAST_IP" ]; then
    NEXT_IP=2
else
    NEXT_IP=$((LAST_IP + 1))
fi

CLIENT_IP="10.8.0.$NEXT_IP"

echo -e "${YELLOW}Creating client: $CLIENT_NAME${NC}"
echo -e "${YELLOW}Client IP: $CLIENT_IP${NC}"

# Generate client keys
cd /etc/wireguard
CLIENT_PRIVATE_KEY=$(wg genkey)
CLIENT_PUBLIC_KEY=$(echo $CLIENT_PRIVATE_KEY | wg pubkey)
CLIENT_PRESHARED_KEY=$(wg genpsk)

# Add peer to server config
cat >> /etc/wireguard/wg0.conf << EOF

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
PresharedKey = $CLIENT_PRESHARED_KEY
AllowedIPs = $CLIENT_IP/32
EOF

# Restart WireGuard
systemctl restart wg-quick@wg0

# Create client config
mkdir -p /root/wireguard-clients
cat > /root/wireguard-clients/${CLIENT_NAME}.conf << EOF
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = $CLIENT_IP/32
DNS = 1.1.1.1, 8.8.8.8

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
PresharedKey = $CLIENT_PRESHARED_KEY
Endpoint = $SERVER_IP:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

# Generate QR code
qrencode -t png -o /root/wireguard-clients/${CLIENT_NAME}-qr.png < /root/wireguard-clients/${CLIENT_NAME}.conf

echo -e "${GREEN}Client created successfully!${NC}"
echo -e "${YELLOW}Configuration file: ${GREEN}/root/wireguard-clients/${CLIENT_NAME}.conf${NC}"
echo -e "${YELLOW}QR Code: ${GREEN}/root/wireguard-clients/${CLIENT_NAME}-qr.png${NC}"
echo ""
echo -e "${YELLOW}Client Configuration:${NC}"
cat /root/wireguard-clients/${CLIENT_NAME}.conf
echo ""
echo -e "${YELLOW}QR Code:${NC}"
qrencode -t ansiutf8 < /root/wireguard-clients/${CLIENT_NAME}.conf
