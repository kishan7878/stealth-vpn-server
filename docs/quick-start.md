# 🚀 Quick Start Guide

## Prerequisites

- A VPS/Cloud server (Ubuntu 20.04+ recommended)
- Root access to the server
- Basic command line knowledge

## Recommended VPS Providers

| Provider | Price | Locations | Bandwidth |
|----------|-------|-----------|-----------|
| **DigitalOcean** | $5/mo | 15+ | 1TB |
| **Vultr** | $3.50/mo | 25+ | 500GB |
| **Linode** | $5/mo | 11+ | 1TB |
| **AWS Lightsail** | $3.50/mo | 20+ | 1TB |

## Step 1: Get a Server

### Option A: DigitalOcean (Recommended)
```bash
# Sign up at https://digitalocean.com
# Create a Droplet:
# - Ubuntu 22.04 LTS
# - Basic plan ($5/month)
# - Choose nearest datacenter
# - Add SSH key
```

### Option B: Vultr
```bash
# Sign up at https://vultr.com
# Deploy new server:
# - Ubuntu 22.04
# - Regular Performance
# - $3.50/month plan
```

## Step 2: Connect to Your Server

```bash
# Replace YOUR_SERVER_IP with your actual server IP
ssh root@YOUR_SERVER_IP
```

## Step 3: Choose Your VPN Protocol

### 🔥 WireGuard (Recommended for Most Users)

**Best for:** Speed, modern devices, general use

```bash
# Download and run setup
git clone https://github.com/kishan7878/stealth-vpn-server.git
cd stealth-vpn-server/wireguard
chmod +x setup.sh
sudo ./setup.sh
```

**Setup time:** ~2 minutes  
**Speed:** ⭐⭐⭐⭐⭐  
**Stealth:** ⭐⭐⭐

### 🥷 Shadowsocks (Best for Bypassing Restrictions)

**Best for:** China, Iran, restrictive networks

```bash
cd stealth-vpn-server/shadowsocks
chmod +x setup.sh
sudo ./setup.sh
```

**Setup time:** ~1 minute  
**Speed:** ⭐⭐⭐⭐  
**Stealth:** ⭐⭐⭐⭐⭐

### 🌐 OpenVPN (Best for Compatibility)

**Best for:** Older devices, maximum compatibility

```bash
cd stealth-vpn-server/openvpn
chmod +x setup.sh
sudo ./setup.sh
```

**Setup time:** ~3 minutes  
**Speed:** ⭐⭐⭐  
**Compatibility:** ⭐⭐⭐⭐⭐

## Step 4: Get Your Configuration

After setup completes, you'll see:

### WireGuard
- Configuration file: `/root/wireguard-clients/client1.conf`
- QR code for mobile: Displayed on screen
- Download to your device

### Shadowsocks
- Connection URL: Displayed on screen
- QR code: Scan with mobile app
- JSON config: `/root/shadowsocks-clients/client-config.json`

### OpenVPN
- Configuration file: `/root/openvpn-clients/client1.ovpn`
- Download to your device

## Step 5: Install Client App

### Windows
- **WireGuard:** https://www.wireguard.com/install/
- **Shadowsocks:** https://github.com/shadowsocks/shadowsocks-windows/releases
- **OpenVPN:** https://openvpn.net/client-connect-vpn-for-windows/

### macOS
- **WireGuard:** App Store
- **Shadowsocks:** https://github.com/shadowsocks/ShadowsocksX-NG/releases
- **OpenVPN:** https://openvpn.net/client-connect-vpn-for-mac-os/

### Android
- **WireGuard:** [Play Store](https://play.google.com/store/apps/details?id=com.wireguard.android)
- **Shadowsocks:** [Play Store](https://play.google.com/store/apps/details?id=com.github.shadowsocks)
- **OpenVPN:** [Play Store](https://play.google.com/store/apps/details?id=net.openvpn.openvpn)

### iOS
- **WireGuard:** [App Store](https://apps.apple.com/app/wireguard/id1441195209)
- **Shadowsocks:** [App Store](https://apps.apple.com/app/shadowrocket/id932747118)
- **OpenVPN:** [App Store](https://apps.apple.com/app/openvpn-connect/id590379981)

## Step 6: Connect

### WireGuard
1. Open WireGuard app
2. Import configuration file or scan QR code
3. Toggle connection ON

### Shadowsocks
1. Open Shadowsocks app
2. Scan QR code or paste connection URL
3. Connect

### OpenVPN
1. Open OpenVPN app
2. Import `.ovpn` file
3. Connect

## Step 7: Verify Connection

Visit these sites to verify:
- https://whatismyipaddress.com
- https://ipleak.net
- https://dnsleaktest.com

Your IP should show your VPS location, not your real location.

## Adding More Devices

### WireGuard
```bash
cd /root/stealth-vpn-server/wireguard
./add-client.sh client2
```

### Shadowsocks
All devices can use the same configuration.

### OpenVPN
```bash
cd /root/stealth-vpn-server/openvpn
./add-client.sh client2
```

## Troubleshooting

### Can't connect?
```bash
# Check if service is running
sudo systemctl status wg-quick@wg0  # WireGuard
sudo systemctl status shadowsocks    # Shadowsocks
sudo systemctl status openvpn@server # OpenVPN

# Check firewall
sudo ufw status
```

### Slow speeds?
- Try a server closer to your location
- Switch to WireGuard for better performance
- Check your VPS bandwidth limits

### Connection drops?
```bash
# Enable persistent keepalive (WireGuard)
# Already configured in our setup

# Check server logs
sudo journalctl -u wg-quick@wg0 -f
```

## Security Tips

1. **Change default ports** (advanced users)
2. **Enable automatic updates:**
   ```bash
   sudo apt install unattended-upgrades
   sudo dpkg-reconfigure -plow unattended-upgrades
   ```
3. **Use strong passwords** for server access
4. **Enable SSH key authentication only**
5. **Regular backups** of configurations

## Cost Optimization

- **$3.50/month:** Vultr basic plan
- **$5/month:** DigitalOcean or Linode
- **Free tier:** AWS (12 months, limited)
- **Free tier:** Google Cloud (90 days, $300 credit)

## Next Steps

- [Advanced Configuration](./advanced-config.md)
- [Performance Tuning](./performance.md)
- [Security Hardening](./security.md)
- [Multi-Server Setup](./multi-server.md)

## Support

Need help? 
- 📧 Open an issue on GitHub
- 💬 Check existing issues for solutions
- 📚 Read the full documentation

---

**Estimated total setup time:** 10-15 minutes  
**Monthly cost:** $3.50 - $5.00  
**Devices supported:** Unlimited
