# 🔒 Stealth VPN Server - Complete Setup

A comprehensive VPN solution with multiple protocols for maximum privacy and undetectability.

## ⚡ One-Click Installation

```bash
curl -fsSL https://raw.githubusercontent.com/kishan7878/stealth-vpn-server/main/install.sh | sudo bash
```

**That's it!** The interactive installer will guide you through the setup process.

---

## 🚀 Features

- **WireGuard** - Fastest modern VPN protocol
- **Shadowsocks** - Stealth mode for bypassing detection
- **OpenVPN** - Industry standard with maximum compatibility
- **Undetectable** - Traffic looks like normal HTTPS
- **One-Click Deploy** - Easy deployment to any server
- **Multi-Device Support** - Connect unlimited devices
- **Docker Support** - Container-based deployment with Web UI
- **Auto-Configuration** - Automatic client config generation
- **QR Codes** - Easy mobile device setup

## 📊 Protocol Comparison

| Feature | WireGuard | Shadowsocks | OpenVPN |
|---------|-----------|-------------|---------|
| **Speed** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Stealth** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Compatibility** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Setup Difficulty** | Easy | Easy | Medium |
| **Mobile Support** | Excellent | Excellent | Good |
| **Battery Usage** | Low | Low | Medium |

## 📋 Quick Start

### Prerequisites

- A VPS/Cloud server (Ubuntu 20.04+, Debian 10+, or CentOS 8+)
- Root access
- 512MB RAM minimum (1GB recommended)
- 10GB disk space

### Recommended VPS Providers

| Provider | Starting Price | Locations | Bandwidth |
|----------|---------------|-----------|-----------|
| [DigitalOcean](https://digitalocean.com) | $5/month | 15+ | 1TB |
| [Vultr](https://vultr.com) | $3.50/month | 25+ | 500GB |
| [Linode](https://linode.com) | $5/month | 11+ | 1TB |
| [AWS Lightsail](https://aws.amazon.com/lightsail/) | $3.50/month | 20+ | 1TB |

### Installation Methods

#### Method 1: One-Click Install (Recommended)

```bash
# Download and run installer
curl -fsSL https://raw.githubusercontent.com/kishan7878/stealth-vpn-server/main/install.sh | sudo bash
```

The installer will:
1. Detect your OS automatically
2. Show an interactive menu
3. Install your chosen VPN protocol(s)
4. Generate client configurations
5. Display connection details

#### Method 2: Manual Installation

```bash
# Clone repository
git clone https://github.com/kishan7878/stealth-vpn-server.git
cd stealth-vpn-server

# Choose your protocol
cd wireguard     # or shadowsocks, or openvpn
chmod +x setup.sh
sudo ./setup.sh
```

#### Method 3: Docker Installation

```bash
# Clone repository
git clone https://github.com/kishan7878/stealth-vpn-server.git
cd stealth-vpn-server

# Configure environment
cp .env.example .env
nano .env  # Update SERVER_IP and passwords

# Start services
docker-compose up -d

# Access WireGuard Web UI
# Open: http://YOUR_SERVER_IP:51821
```

## 🎯 Protocol Selection Guide

### Choose WireGuard if:
- ✅ You want the fastest speeds
- ✅ You use modern devices (2018+)
- ✅ You need low battery consumption
- ✅ You want easy mobile setup (QR codes)

### Choose Shadowsocks if:
- ✅ You're in China, Iran, or restrictive countries
- ✅ You need maximum stealth
- ✅ You want to bypass deep packet inspection
- ✅ You need traffic that looks like HTTPS

### Choose OpenVPN if:
- ✅ You need maximum compatibility
- ✅ You use older devices
- ✅ You need corporate-level features
- ✅ You want the most tested solution

### Install All if:
- ✅ You want maximum flexibility
- ✅ You want to test different protocols
- ✅ You have multiple use cases
- ✅ You want to switch protocols anytime

## 📱 Client Setup

### Download Clients

#### Windows
- **WireGuard:** https://www.wireguard.com/install/
- **Shadowsocks:** https://github.com/shadowsocks/shadowsocks-windows/releases
- **OpenVPN:** https://openvpn.net/client-connect-vpn-for-windows/

#### macOS
- **WireGuard:** App Store or https://www.wireguard.com/install/
- **Shadowsocks:** https://github.com/shadowsocks/ShadowsocksX-NG/releases
- **OpenVPN:** https://openvpn.net/client-connect-vpn-for-mac-os/

#### Android
- **WireGuard:** [Play Store](https://play.google.com/store/apps/details?id=com.wireguard.android)
- **Shadowsocks:** [Play Store](https://play.google.com/store/apps/details?id=com.github.shadowsocks)
- **OpenVPN:** [Play Store](https://play.google.com/store/apps/details?id=net.openvpn.openvpn)

#### iOS
- **WireGuard:** [App Store](https://apps.apple.com/app/wireguard/id1441195209)
- **Shadowsocks:** [App Store](https://apps.apple.com/app/shadowrocket/id932747118)
- **OpenVPN:** [App Store](https://apps.apple.com/app/openvpn-connect/id590379981)

#### Linux
```bash
# WireGuard
sudo apt install wireguard
sudo wg-quick up wg0

# Shadowsocks
pip3 install shadowsocks
sslocal -c config.json

# OpenVPN
sudo apt install openvpn
sudo openvpn --config client.ovpn
```

### Configuration Files Location

After installation, find your client configurations:

- **WireGuard:** `/root/wireguard-clients/`
- **Shadowsocks:** `/root/shadowsocks-clients/`
- **OpenVPN:** `/root/openvpn-clients/`

## 🔧 Management

### Add More Clients

```bash
# WireGuard
cd /root/stealth-vpn-server/wireguard
./add-client.sh client-name

# OpenVPN
cd /root/stealth-vpn-server/openvpn
./add-client.sh client-name

# Shadowsocks (all devices use same config)
cat /root/shadowsocks-clients/connection-url.txt
```

### Check Service Status

```bash
# WireGuard
sudo systemctl status wg-quick@wg0

# Shadowsocks
sudo systemctl status shadowsocks

# OpenVPN
sudo systemctl status openvpn@server

# Docker
docker-compose ps
```

### View Logs

```bash
# WireGuard
sudo journalctl -u wg-quick@wg0 -f

# Shadowsocks
sudo journalctl -u shadowsocks -f

# OpenVPN
sudo journalctl -u openvpn@server -f

# Docker
docker-compose logs -f
```

### Restart Services

```bash
# WireGuard
sudo systemctl restart wg-quick@wg0

# Shadowsocks
sudo systemctl restart shadowsocks

# OpenVPN
sudo systemctl restart openvpn@server

# Docker
docker-compose restart
```

## 🔍 Verification

### Verify Installation

```bash
cd /root/stealth-vpn-server
chmod +x verify-installation.sh
sudo ./verify-installation.sh
```

### Test Your Connection

After connecting to VPN, visit these sites:

1. **IP Check:** https://whatismyipaddress.com
   - Should show your VPS IP, not your real IP

2. **DNS Leak Test:** https://dnsleaktest.com
   - Should show your VPS location

3. **WebRTC Leak Test:** https://browserleaks.com/webrtc
   - Should not reveal your real IP

4. **Full Test:** https://ipleak.net
   - Comprehensive leak detection

## 🛡️ Security Features

- ✅ **Strong Encryption**
  - WireGuard: ChaCha20-Poly1305
  - Shadowsocks: ChaCha20-IETF-Poly1305
  - OpenVPN: AES-256-GCM with SHA512

- ✅ **Perfect Forward Secrecy**
  - All protocols support PFS

- ✅ **DNS Leak Protection**
  - Configured with Cloudflare (1.1.1.1) and Google (8.8.8.8) DNS

- ✅ **Kill Switch Support**
  - Prevents traffic leaks if VPN disconnects

- ✅ **No Logging**
  - Minimal logging for privacy

- ✅ **Traffic Obfuscation**
  - Shadowsocks makes traffic look like HTTPS

## 📚 Documentation

- [Quick Start Guide](./docs/quick-start.md) - Detailed setup instructions
- [Docker Deployment](./docs/docker-deployment.md) - Container-based setup
- [Security Best Practices](./docs/security.md) - Hardening your VPN
- [Troubleshooting Guide](./docs/troubleshooting.md) - Common issues and solutions

## 🔧 Advanced Configuration

### Change Ports

```bash
# WireGuard
sudo nano /etc/wireguard/wg0.conf
# Change ListenPort value

# Shadowsocks
sudo nano /etc/shadowsocks/config.json
# Change server_port value

# OpenVPN
sudo nano /etc/openvpn/server.conf
# Change port value
```

### Custom DNS Servers

```bash
# WireGuard - Edit client config
DNS = 1.1.1.1, 9.9.9.9

# OpenVPN - Edit server config
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 9.9.9.9"
```

### Performance Tuning

See [Performance Guide](./docs/performance.md) for optimization tips.

## 💰 Cost Breakdown

### Monthly Costs

- **VPS Server:** $3.50 - $5.00/month
- **Domain (optional):** $1/month
- **Total:** ~$5/month for unlimited devices

### Cost Comparison

| Solution | Monthly Cost | Devices | Speed | Privacy |
|----------|-------------|---------|-------|---------|
| **Self-Hosted VPN** | $5 | Unlimited | Full | Complete |
| Commercial VPN | $10-15 | 5-10 | Limited | Shared |
| Free VPN | $0 | 1-2 | Very Slow | Poor |

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Areas for Contribution

- [ ] Additional VPN protocols (IKEv2, L2TP)
- [ ] Automated testing
- [ ] Performance benchmarks
- [ ] Multi-language support
- [ ] Web management interface improvements

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

## ⚠️ Disclaimer

This software is provided for educational and privacy purposes. Users are responsible for complying with local laws and regulations. The authors are not responsible for any misuse of this software.

## 🆘 Support

- 📧 **Issues:** [GitHub Issues](https://github.com/kishan7878/stealth-vpn-server/issues)
- 📚 **Documentation:** Check `/docs` folder
- 💬 **Discussions:** [GitHub Discussions](https://github.com/kishan7878/stealth-vpn-server/discussions)

## 🌟 Star History

If you find this project useful, please consider giving it a star! ⭐

## 📊 Statistics

- **Setup Time:** 5-10 minutes
- **Supported OS:** Ubuntu, Debian, CentOS
- **Protocols:** 3 (WireGuard, Shadowsocks, OpenVPN)
- **Devices:** Unlimited
- **Cost:** ~$5/month

## 🎯 Use Cases

- ✅ **Privacy Protection** - Hide your IP and encrypt traffic
- ✅ **Bypass Censorship** - Access blocked websites
- ✅ **Secure Public WiFi** - Protect on untrusted networks
- ✅ **Remote Access** - Securely access home network
- ✅ **Geo-Unblocking** - Access region-restricted content
- ✅ **Business Use** - Secure remote team connections

## 🔗 Quick Links

- [Installation Guide](./docs/quick-start.md)
- [Docker Setup](./docs/docker-deployment.md)
- [Security Guide](./docs/security.md)
- [Troubleshooting](./docs/troubleshooting.md)
- [GitHub Repository](https://github.com/kishan7878/stealth-vpn-server)

---

<div align="center">

**Made with ❤️ for privacy and freedom**

[⬆ Back to Top](#-stealth-vpn-server---complete-setup)

</div>
