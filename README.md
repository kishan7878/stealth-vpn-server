# 🔒 Stealth VPN Server - Complete Setup

A comprehensive VPN solution with multiple protocols for maximum privacy and undetectability.

## 🚀 Features

- **WireGuard** - Fastest modern VPN protocol
- **Shadowsocks** - Stealth mode for bypassing detection
- **OpenVPN** - Industry standard with maximum compatibility
- **Undetectable** - Traffic looks like normal HTTPS
- **One-Click Deploy** - Easy deployment to Railway, DigitalOcean, AWS
- **Multi-Device Support** - Connect unlimited devices

## 📋 Quick Start

### Option 1: WireGuard (Recommended) ⚡

**Best for:** Speed, security, and modern devices

```bash
# Deploy to your server
git clone https://github.com/kishan7878/stealth-vpn-server.git
cd stealth-vpn-server/wireguard
chmod +x setup.sh
sudo ./setup.sh
```

### Option 2: Shadowsocks (Maximum Stealth) 🥷

**Best for:** Bypassing firewalls and deep packet inspection

```bash
cd shadowsocks
chmod +x setup.sh
sudo ./setup.sh
```

### Option 3: OpenVPN (Maximum Compatibility) 🌐

**Best for:** Older devices and maximum compatibility

```bash
cd openvpn
chmod +x setup.sh
sudo ./setup.sh
```

## 🎯 One-Click Deployment

### Deploy to Railway
[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/wireguard)

### Deploy to DigitalOcean
[![Deploy to DO](https://www.deploytodo.com/do-btn-blue.svg)](https://marketplace.digitalocean.com/apps/wireguard)

### Deploy to AWS
See [AWS Deployment Guide](./docs/aws-deployment.md)

## 📱 Client Setup

### Windows
1. Download [WireGuard Client](https://www.wireguard.com/install/)
2. Import the `.conf` file generated during setup
3. Click "Activate"

### macOS
1. Install WireGuard from App Store
2. Import configuration file
3. Connect

### Android/iOS
1. Install WireGuard app
2. Scan QR code (generated during setup)
3. Connect

### Linux
```bash
sudo apt install wireguard
sudo wg-quick up wg0
```

## 🔧 Configuration

### WireGuard Configuration
Located in: `wireguard/wg0.conf`

### Shadowsocks Configuration
Located in: `shadowsocks/config.json`

### OpenVPN Configuration
Located in: `openvpn/server.conf`

## 🛡️ Security Features

- ✅ Strong encryption (ChaCha20-Poly1305)
- ✅ Perfect Forward Secrecy
- ✅ DNS leak protection
- ✅ Kill switch support
- ✅ No logging policy
- ✅ Traffic obfuscation

## 📊 Performance

| Protocol | Speed | Stealth | Compatibility |
|----------|-------|---------|---------------|
| WireGuard | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| Shadowsocks | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| OpenVPN | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

## 🌍 Server Locations

Recommended VPS providers:
- **DigitalOcean** - $5/month, multiple locations
- **Vultr** - $3.50/month, 25+ locations
- **Linode** - $5/month, reliable
- **AWS Lightsail** - $3.50/month, global coverage

## 🔍 Troubleshooting

### Connection Issues
```bash
# Check server status
sudo systemctl status wg-quick@wg0

# View logs
sudo journalctl -u wg-quick@wg0 -f
```

### Firewall Configuration
```bash
# Allow VPN ports
sudo ufw allow 51820/udp  # WireGuard
sudo ufw allow 8388/tcp   # Shadowsocks
sudo ufw allow 1194/udp   # OpenVPN
```

## 📚 Documentation

- [WireGuard Setup Guide](./docs/wireguard-setup.md)
- [Shadowsocks Setup Guide](./docs/shadowsocks-setup.md)
- [OpenVPN Setup Guide](./docs/openvpn-setup.md)
- [Client Configuration](./docs/client-setup.md)
- [Security Best Practices](./docs/security.md)

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

## ⚠️ Disclaimer

This software is provided for educational and privacy purposes. Users are responsible for complying with local laws and regulations.

## 🆘 Support

- 📧 Email: support@example.com
- 💬 Discord: [Join Server](https://discord.gg/example)
- 🐛 Issues: [GitHub Issues](https://github.com/kishan7878/stealth-vpn-server/issues)

---

Made with ❤️ for privacy and freedom
