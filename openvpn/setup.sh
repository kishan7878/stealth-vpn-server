#!/bin/bash

# OpenVPN Server Setup Script
# Maximum compatibility with all devices

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}OpenVPN Server Setup${NC}"
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

# Install OpenVPN and Easy-RSA
echo -e "${YELLOW}Installing OpenVPN...${NC}"
case $OS in
    ubuntu|debian)
        apt update
        apt install -y openvpn easy-rsa qrencode
        ;;
    centos|rhel|fedora)
        yum install -y epel-release
        yum install -y openvpn easy-rsa qrencode
        ;;
    *)
        echo -e "${RED}Unsupported OS${NC}"
        exit 1
        ;;
esac

# Get server IP
SERVER_IP=$(curl -s ifconfig.me)
if [ -z "$SERVER_IP" ]; then
    SERVER_IP=$(ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d/ -f1 | head -n1)
fi

# Setup Easy-RSA
echo -e "${YELLOW}Setting up PKI...${NC}"
make-cadir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa

# Configure Easy-RSA vars
cat > vars << EOF
set_var EASYRSA_REQ_COUNTRY    "US"
set_var EASYRSA_REQ_PROVINCE   "California"
set_var EASYRSA_REQ_CITY       "San Francisco"
set_var EASYRSA_REQ_ORG        "MyVPN"
set_var EASYRSA_REQ_EMAIL      "admin@myvpn.com"
set_var EASYRSA_REQ_OU         "MyVPN"
set_var EASYRSA_ALGO           "ec"
set_var EASYRSA_DIGEST         "sha512"
EOF

# Initialize PKI
./easyrsa init-pki
./easyrsa --batch build-ca nopass
./easyrsa gen-dh
./easyrsa build-server-full server nopass
./easyrsa build-client-full client1 nopass
openvpn --genkey secret pki/ta.key

# Copy certificates
cp pki/ca.crt pki/private/ca.key pki/dh.pem pki/issued/server.crt pki/private/server.key pki/ta.key /etc/openvpn/

# Get network interface
NET_INTERFACE=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)

# Create server configuration
echo -e "${YELLOW}Creating server configuration...${NC}"
cat > /etc/openvpn/server.conf << EOF
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-auth ta.key 0
cipher AES-256-GCM
auth SHA512
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.8.8"
keepalive 10 120
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
verb 3
explicit-exit-notify 1
EOF

# Enable IP forwarding
echo -e "${YELLOW}Enabling IP forwarding...${NC}"
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Configure NAT
echo -e "${YELLOW}Configuring NAT...${NC}"
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $NET_INTERFACE -j MASQUERADE
iptables-save > /etc/iptables.rules

# Create iptables restore service
cat > /etc/systemd/system/iptables-restore.service << EOF
[Unit]
Description=Restore iptables rules
Before=network-pre.target

[Service]
Type=oneshot
ExecStart=/sbin/iptables-restore /etc/iptables.rules

[Install]
WantedBy=multi-user.target
EOF

systemctl enable iptables-restore

# Configure firewall
echo -e "${YELLOW}Configuring firewall...${NC}"
if command -v ufw &> /dev/null; then
    ufw allow 1194/udp
    ufw --force enable
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=1194/udp
    firewall-cmd --reload
fi

# Start OpenVPN
echo -e "${YELLOW}Starting OpenVPN...${NC}"
systemctl enable openvpn@server
systemctl start openvpn@server

# Create client configuration
echo -e "${YELLOW}Creating client configuration...${NC}"
mkdir -p /root/openvpn-clients

cat > /root/openvpn-clients/client1.ovpn << EOF
client
dev tun
proto udp
remote $SERVER_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-GCM
auth SHA512
verb 3
<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
<cert>
$(cat /etc/openvpn/easy-rsa/pki/issued/client1.crt)
</cert>
<key>
$(cat /etc/openvpn/easy-rsa/pki/private/client1.key)
</key>
<tls-auth>
$(cat /etc/openvpn/ta.key)
</tls-auth>
key-direction 1
EOF

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}OpenVPN Setup Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${YELLOW}Server Information:${NC}"
echo -e "Server IP: ${GREEN}$SERVER_IP${NC}"
echo -e "Server Port: ${GREEN}1194${NC}"
echo -e "Protocol: ${GREEN}UDP${NC}"
echo ""
echo -e "${YELLOW}Client Configuration:${NC}"
echo -e "Location: ${GREEN}/root/openvpn-clients/client1.ovpn${NC}"
echo ""
echo -e "${YELLOW}Download OpenVPN Client:${NC}"
echo -e "Windows: ${GREEN}https://openvpn.net/client-connect-vpn-for-windows/${NC}"
echo -e "macOS: ${GREEN}https://openvpn.net/client-connect-vpn-for-mac-os/${NC}"
echo -e "Android: ${GREEN}https://play.google.com/store/apps/details?id=net.openvpn.openvpn${NC}"
echo -e "iOS: ${GREEN}https://apps.apple.com/app/openvpn-connect/id590379981${NC}"
echo ""
echo -e "${YELLOW}To add more clients, run:${NC}"
echo -e "${GREEN}./add-client.sh <client-name>${NC}"
echo ""
echo -e "${GREEN}Setup completed successfully!${NC}"
