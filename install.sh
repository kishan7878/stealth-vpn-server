#!/bin/bash

# One-Click VPN Installation Script
# Automatically detects and installs the best VPN solution for your needs

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

clear

cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║        🔒 STEALTH VPN SERVER - ONE-CLICK INSTALLER       ║
║                                                           ║
║     Fast • Secure • Undetectable • Easy to Use           ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF

echo ""
echo -e "${CYAN}Welcome to the Stealth VPN Server installer!${NC}"
echo -e "${CYAN}This script will help you set up a secure VPN in minutes.${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ This script must be run as root${NC}" 
   echo -e "${YELLOW}Please run: sudo $0${NC}"
   exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    OS_VERSION=$VERSION_ID
else
    echo -e "${RED}❌ Cannot detect OS${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Detected OS: $OS $OS_VERSION"
echo ""

# Check supported OS
case $OS in
    ubuntu|debian)
        if [ "$OS" = "ubuntu" ] && [ "${OS_VERSION%%.*}" -lt 20 ]; then
            echo -e "${RED}❌ Ubuntu 20.04 or higher required${NC}"
            exit 1
        fi
        if [ "$OS" = "debian" ] && [ "${OS_VERSION%%.*}" -lt 10 ]; then
            echo -e "${RED}❌ Debian 10 or higher required${NC}"
            exit 1
        fi
        ;;
    centos|rhel|fedora)
        if [ "${OS_VERSION%%.*}" -lt 8 ]; then
            echo -e "${RED}❌ CentOS/RHEL 8 or higher required${NC}"
            exit 1
        fi
        ;;
    *)
        echo -e "${RED}❌ Unsupported OS: $OS${NC}"
        echo -e "${YELLOW}Supported: Ubuntu 20.04+, Debian 10+, CentOS 8+${NC}"
        exit 1
        ;;
esac

# Interactive menu
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Choose your VPN protocol:${NC}"
echo ""
echo -e "${GREEN}1)${NC} WireGuard ${YELLOW}(Recommended)${NC}"
echo -e "   ⚡ Fastest performance"
echo -e "   🔒 Modern encryption"
echo -e "   📱 Great for mobile devices"
echo -e "   ⭐ Best for: General use, speed"
echo ""
echo -e "${GREEN}2)${NC} Shadowsocks ${YELLOW}(Maximum Stealth)${NC}"
echo -e "   🥷 Undetectable traffic"
echo -e "   🌍 Bypasses censorship"
echo -e "   🚀 Fast and lightweight"
echo -e "   ⭐ Best for: China, Iran, restrictive networks"
echo ""
echo -e "${GREEN}3)${NC} OpenVPN ${YELLOW}(Maximum Compatibility)${NC}"
echo -e "   🌐 Works everywhere"
echo -e "   🔧 Highly configurable"
echo -e "   📊 Industry standard"
echo -e "   ⭐ Best for: Older devices, corporate use"
echo ""
echo -e "${GREEN}4)${NC} Install All ${YELLOW}(Complete Setup)${NC}"
echo -e "   🎯 All protocols in one server"
echo -e "   🔄 Switch between protocols anytime"
echo -e "   💪 Maximum flexibility"
echo ""
echo -e "${GREEN}5)${NC} Docker Installation ${YELLOW}(Easy Management)${NC}"
echo -e "   🐳 Container-based deployment"
echo -e "   🎛️ Web UI included"
echo -e "   🔄 Easy updates"
echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${NC}"
echo ""

read -p "$(echo -e ${CYAN}Enter your choice [1-5]: ${NC})" choice

case $choice in
    1)
        INSTALL_TYPE="wireguard"
        echo -e "${GREEN}✓${NC} Installing WireGuard..."
        ;;
    2)
        INSTALL_TYPE="shadowsocks"
        echo -e "${GREEN}✓${NC} Installing Shadowsocks..."
        ;;
    3)
        INSTALL_TYPE="openvpn"
        echo -e "${GREEN}✓${NC} Installing OpenVPN..."
        ;;
    4)
        INSTALL_TYPE="all"
        echo -e "${GREEN}✓${NC} Installing all VPN protocols..."
        ;;
    5)
        INSTALL_TYPE="docker"
        echo -e "${GREEN}✓${NC} Installing Docker-based setup..."
        ;;
    *)
        echo -e "${RED}❌ Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${YELLOW}⏳ Starting installation...${NC}"
echo ""

# Clone repository if not already present
if [ ! -d "stealth-vpn-server" ]; then
    echo -e "${CYAN}📥 Downloading installation files...${NC}"
    apt-get update -qq
    apt-get install -y git curl wget -qq
    git clone https://github.com/kishan7878/stealth-vpn-server.git
    cd stealth-vpn-server
else
    cd stealth-vpn-server
    git pull -q
fi

# Docker installation
if [ "$INSTALL_TYPE" = "docker" ]; then
    echo -e "${CYAN}🐳 Installing Docker...${NC}"
    
    # Install Docker
    if ! command -v docker &> /dev/null; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
    fi
    
    # Install Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi
    
    # Setup environment
    if [ ! -f .env ]; then
        cp .env.example .env
        SERVER_IP=$(curl -s ifconfig.me)
        sed -i "s/your.server.ip.here/$SERVER_IP/" .env
        
        # Generate random passwords
        SS_PASS=$(openssl rand -base64 24)
        WG_PASS=$(openssl rand -base64 16)
        sed -i "s/YourStrongPasswordHere123!/$SS_PASS/" .env
        sed -i "s/SecureAdminPassword123!/$WG_PASS/" .env
    fi
    
    # Start services
    echo -e "${CYAN}🚀 Starting VPN services...${NC}"
    docker-compose up -d
    
    sleep 5
    
    # Get credentials
    SERVER_IP=$(grep SERVER_IP .env | cut -d'=' -f2)
    WG_PASS=$(grep WG_ADMIN_PASSWORD .env | cut -d'=' -f2)
    SS_PASS=$(grep SS_PASSWORD .env | cut -d'=' -f2)
    
    clear
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║              ✅ INSTALLATION SUCCESSFUL!                  ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo ""
    echo -e "${GREEN}🎉 Your VPN server is ready!${NC}"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}WireGuard Web UI:${NC}"
    echo -e "  URL: ${GREEN}http://$SERVER_IP:51821${NC}"
    echo -e "  Password: ${GREEN}$WG_PASS${NC}"
    echo ""
    echo -e "${YELLOW}Shadowsocks:${NC}"
    echo -e "  Server: ${GREEN}$SERVER_IP${NC}"
    echo -e "  Port: ${GREEN}8388${NC}"
    echo -e "  Password: ${GREEN}$SS_PASS${NC}"
    echo -e "  Method: ${GREEN}chacha20-ietf-poly1305${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    
else
    # Traditional installation
    case $INSTALL_TYPE in
        wireguard)
            cd wireguard
            chmod +x setup.sh
            ./setup.sh
            ;;
        shadowsocks)
            cd shadowsocks
            chmod +x setup.sh
            ./setup.sh
            ;;
        openvpn)
            cd openvpn
            chmod +x setup.sh
            ./setup.sh
            ;;
        all)
            echo -e "${CYAN}Installing WireGuard...${NC}"
            cd wireguard
            chmod +x setup.sh
            ./setup.sh
            cd ..
            
            echo ""
            echo -e "${CYAN}Installing Shadowsocks...${NC}"
            cd shadowsocks
            chmod +x setup.sh
            ./setup.sh
            cd ..
            
            echo ""
            echo -e "${CYAN}Installing OpenVPN...${NC}"
            cd openvpn
            chmod +x setup.sh
            ./setup.sh
            cd ..
            ;;
    esac
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}📱 Next Steps:${NC}"
echo ""
echo -e "1. ${YELLOW}Download VPN client for your device:${NC}"
echo -e "   • Windows/Mac/Linux: Visit official websites"
echo -e "   • Android/iOS: Install from app stores"
echo ""
echo -e "2. ${YELLOW}Import configuration:${NC}"
echo -e "   • Scan QR code (mobile)"
echo -e "   • Import config file (desktop)"
echo ""
echo -e "3. ${YELLOW}Test your connection:${NC}"
echo -e "   • Visit: ${GREEN}https://ipleak.net${NC}"
echo -e "   • Your IP should show: ${GREEN}$(curl -s ifconfig.me)${NC}"
echo ""
echo -e "4. ${YELLOW}Verify installation:${NC}"
echo -e "   • Run: ${GREEN}./verify-installation.sh${NC}"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}📚 Documentation:${NC}"
echo -e "   • Quick Start: ${BLUE}docs/quick-start.md${NC}"
echo -e "   • Troubleshooting: ${BLUE}docs/troubleshooting.md${NC}"
echo -e "   • Security Guide: ${BLUE}docs/security.md${NC}"
echo ""
echo -e "${GREEN}🆘 Need Help?${NC}"
echo -e "   • GitHub Issues: ${BLUE}https://github.com/kishan7878/stealth-vpn-server/issues${NC}"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Thank you for using Stealth VPN Server! 🚀${NC}"
echo ""
