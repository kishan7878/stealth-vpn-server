#!/bin/bash

# Shadowsocks VPN Server Setup Script
# Maximum stealth mode for bypassing detection

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Shadowsocks Server Setup${NC}"
echo -e "${GREEN}================================${NC}"

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

# Install dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
case $OS in
    ubuntu|debian)
        apt update
        apt install -y python3-pip qrencode
        ;;
    centos|rhel|fedora)
        yum install -y python3-pip qrencode
        ;;
    *)
        echo -e "${RED}Unsupported OS${NC}"
        exit 1
        ;;
esac

# Install shadowsocks
echo -e "${YELLOW}Installing Shadowsocks...${NC}"
pip3 install shadowsocks

# Generate random password
PASSWORD=$(openssl rand -base64 32)
PORT=8388

# Get server IP
SERVER_IP=$(curl -s ifconfig.me)
if [ -z "$SERVER_IP" ]; then
    SERVER_IP=$(ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d/ -f1 | head -n1)
fi

# Create config directory
mkdir -p /etc/shadowsocks

# Create server configuration
echo -e "${YELLOW}Creating server configuration...${NC}"
cat > /etc/shadowsocks/config.json << EOF
{
    "server": "0.0.0.0",
    "server_port": $PORT,
    "password": "$PASSWORD",
    "timeout": 300,
    "method": "chacha20-ietf-poly1305",
    "fast_open": true,
    "workers": 4
}
EOF

# Create systemd service
echo -e "${YELLOW}Creating systemd service...${NC}"
cat > /etc/systemd/system/shadowsocks.service << EOF
[Unit]
Description=Shadowsocks Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ssserver -c /etc/shadowsocks/config.json
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# Configure firewall
echo -e "${YELLOW}Configuring firewall...${NC}"
if command -v ufw &> /dev/null; then
    ufw allow $PORT/tcp
    ufw --force enable
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=$PORT/tcp
    firewall-cmd --reload
fi

# Start service
echo -e "${YELLOW}Starting Shadowsocks...${NC}"
systemctl daemon-reload
systemctl enable shadowsocks
systemctl start shadowsocks

# Create client configuration
mkdir -p /root/shadowsocks-clients

# Create client config JSON
cat > /root/shadowsocks-clients/client-config.json << EOF
{
    "server": "$SERVER_IP",
    "server_port": $PORT,
    "password": "$PASSWORD",
    "method": "chacha20-ietf-poly1305",
    "remarks": "My Stealth VPN"
}
EOF

# Create ss:// URL for easy import
SS_URL="ss://$(echo -n "chacha20-ietf-poly1305:$PASSWORD@$SERVER_IP:$PORT" | base64 -w 0)"

# Save URL to file
echo "$SS_URL" > /root/shadowsocks-clients/connection-url.txt

# Generate QR code
echo "$SS_URL" | qrencode -t ansiutf8 > /root/shadowsocks-clients/qr-code.txt
echo "$SS_URL" | qrencode -t png -o /root/shadowsocks-clients/qr-code.png

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Shadowsocks Setup Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${YELLOW}Server Information:${NC}"
echo -e "Server IP: ${GREEN}$SERVER_IP${NC}"
echo -e "Server Port: ${GREEN}$PORT${NC}"
echo -e "Password: ${GREEN}$PASSWORD${NC}"
echo -e "Encryption: ${GREEN}chacha20-ietf-poly1305${NC}"
echo ""
echo -e "${YELLOW}Connection URL:${NC}"
echo -e "${GREEN}$SS_URL${NC}"
echo ""
echo -e "${YELLOW}Client Configuration:${NC}"
echo -e "JSON Config: ${GREEN}/root/shadowsocks-clients/client-config.json${NC}"
echo -e "Connection URL: ${GREEN}/root/shadowsocks-clients/connection-url.txt${NC}"
echo -e "QR Code: ${GREEN}/root/shadowsocks-clients/qr-code.png${NC}"
echo ""
echo -e "${YELLOW}Download Shadowsocks Client:${NC}"
echo -e "Windows: ${GREEN}https://github.com/shadowsocks/shadowsocks-windows/releases${NC}"
echo -e "macOS: ${GREEN}https://github.com/shadowsocks/ShadowsocksX-NG/releases${NC}"
echo -e "Android: ${GREEN}https://play.google.com/store/apps/details?id=com.github.shadowsocks${NC}"
echo -e "iOS: ${GREEN}https://apps.apple.com/app/shadowrocket/id932747118${NC}"
echo ""
echo -e "${YELLOW}Scan this QR code with your mobile device:${NC}"
cat /root/shadowsocks-clients/qr-code.txt
echo ""
echo -e "${GREEN}Setup completed successfully!${NC}"
