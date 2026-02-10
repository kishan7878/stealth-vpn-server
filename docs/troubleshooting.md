# 🔧 Troubleshooting Guide

Common issues and their solutions.

## Installation Issues

### Script Fails to Run

**Problem:** Permission denied when running setup script

**Solution:**
```bash
chmod +x setup.sh
sudo ./setup.sh
```

### Package Installation Fails

**Problem:** Unable to install packages

**Solution:**
```bash
# Update package lists
sudo apt update

# Fix broken packages
sudo apt --fix-broken install

# Try again
sudo apt install wireguard
```

### Unsupported OS

**Problem:** Script doesn't support your OS

**Solution:**
- Use Ubuntu 20.04+ or Debian 10+ (recommended)
- Or manually install packages for your OS
- Check official documentation for your distribution

## Connection Issues

### Can't Connect to VPN

**Check 1: Service Status**
```bash
# WireGuard
sudo systemctl status wg-quick@wg0

# Shadowsocks
sudo systemctl status shadowsocks

# OpenVPN
sudo systemctl status openvpn@server
```

**Check 2: Firewall**
```bash
# Check if ports are open
sudo ufw status

# Allow VPN ports
sudo ufw allow 51820/udp  # WireGuard
sudo ufw allow 8388/tcp   # Shadowsocks
sudo ufw allow 1194/udp   # OpenVPN
```

**Check 3: Server IP**
```bash
# Verify server IP
curl ifconfig.me

# Update client config with correct IP
```

### Connection Drops Frequently

**Solution 1: Enable Keepalive**

WireGuard - Add to client config:
```ini
[Peer]
PersistentKeepalive = 25
```

OpenVPN - Add to client config:
```
keepalive 10 60
```

**Solution 2: Check Network Stability**
```bash
# Test connection to server
ping YOUR_SERVER_IP

# Check packet loss
mtr YOUR_SERVER_IP
```

### Slow Connection Speed

**Check 1: Server Resources**
```bash
# Check CPU usage
top

# Check memory
free -h

# Check bandwidth
iftop
```

**Check 2: MTU Settings**

WireGuard:
```ini
[Interface]
MTU = 1420
```

OpenVPN:
```
tun-mtu 1500
mssfix 1450
```

**Check 3: Server Location**
- Use server closer to your location
- Test different VPS providers

## DNS Issues

### DNS Leaks

**Test for leaks:**
- Visit https://dnsleaktest.com
- Run extended test

**Fix for WireGuard:**
```ini
[Interface]
DNS = 1.1.1.1, 8.8.8.8
```

**Fix for OpenVPN:**
```
dhcp-option DNS 1.1.1.1
dhcp-option DNS 8.8.8.8
```

### Can't Resolve Domains

**Solution:**
```bash
# Test DNS resolution
nslookup google.com 1.1.1.1

# Update DNS servers
sudo nano /etc/resolv.conf
# Add:
nameserver 1.1.1.1
nameserver 8.8.8.8
```

## Service Issues

### Service Won't Start

**WireGuard:**
```bash
# Check configuration
sudo wg-quick up wg0

# View errors
sudo journalctl -u wg-quick@wg0 -n 50

# Common fixes:
# 1. Check IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1

# 2. Check interface conflicts
ip link show

# 3. Reload configuration
sudo systemctl restart wg-quick@wg0
```

**Shadowsocks:**
```bash
# Check configuration
cat /etc/shadowsocks/config.json

# Test manually
ssserver -c /etc/shadowsocks/config.json

# View logs
sudo journalctl -u shadowsocks -n 50

# Restart service
sudo systemctl restart shadowsocks
```

**OpenVPN:**
```bash
# Test configuration
sudo openvpn --config /etc/openvpn/server.conf

# View logs
sudo journalctl -u openvpn@server -n 50

# Check certificates
ls -la /etc/openvpn/*.crt /etc/openvpn/*.key

# Restart service
sudo systemctl restart openvpn@server
```

### Service Crashes

**Check logs:**
```bash
# System logs
sudo journalctl -xe

# Specific service
sudo journalctl -u SERVICE_NAME -n 100

# Kernel logs
dmesg | tail -50
```

**Common causes:**
1. Out of memory
2. Port conflicts
3. Configuration errors
4. Missing dependencies

## Client Issues

### Can't Import Configuration

**WireGuard:**
- Ensure file has `.conf` extension
- Check file permissions
- Verify configuration syntax

**OpenVPN:**
- Ensure file has `.ovpn` extension
- Check for embedded certificates
- Try importing as text

**Shadowsocks:**
- Verify URL format: `ss://METHOD:PASSWORD@SERVER:PORT`
- Try manual configuration
- Check for special characters in password

### Authentication Fails

**WireGuard:**
```bash
# Regenerate keys
cd /etc/wireguard
wg genkey | tee client_private.key | wg pubkey > client_public.key

# Update server config with new public key
sudo nano /etc/wireguard/wg0.conf

# Restart service
sudo systemctl restart wg-quick@wg0
```

**OpenVPN:**
```bash
# Regenerate client certificate
cd /etc/openvpn/easy-rsa
./easyrsa revoke client1
./easyrsa build-client-full client1 nopass

# Generate new .ovpn file
```

## Network Issues

### IP Forwarding Not Working

**Check:**
```bash
cat /proc/sys/net/ipv4/ip_forward
# Should output: 1
```

**Fix:**
```bash
# Temporary
sudo sysctl -w net.ipv4.ip_forward=1

# Permanent
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### NAT Not Working

**Check iptables:**
```bash
sudo iptables -t nat -L -n -v
```

**Fix:**
```bash
# Get network interface
ip route | grep default

# Add NAT rule (replace eth0 with your interface)
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Save rules
sudo iptables-save | sudo tee /etc/iptables.rules
```

### Port Already in Use

**Find process using port:**
```bash
sudo lsof -i :51820  # WireGuard
sudo lsof -i :8388   # Shadowsocks
sudo lsof -i :1194   # OpenVPN
```

**Kill process:**
```bash
sudo kill -9 PID
```

**Or change port:**
```bash
# Edit configuration file
sudo nano /etc/wireguard/wg0.conf
# Change ListenPort value
```

## Performance Issues

### High CPU Usage

**Check processes:**
```bash
top
htop  # If installed
```

**Solutions:**
1. Reduce number of connected clients
2. Upgrade server resources
3. Optimize encryption settings
4. Use WireGuard (most efficient)

### High Memory Usage

**Check memory:**
```bash
free -h
```

**Solutions:**
```bash
# Clear cache
sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches

# Add swap space
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Bandwidth Limits

**Monitor bandwidth:**
```bash
# Install iftop
sudo apt install iftop

# Monitor
sudo iftop -i wg0
```

**Set limits (optional):**
```bash
# Using tc (traffic control)
sudo tc qdisc add dev wg0 root tbf rate 10mbit burst 32kbit latency 400ms
```

## Security Issues

### Unauthorized Access

**Check connected clients:**
```bash
# WireGuard
sudo wg show

# OpenVPN
cat /etc/openvpn/openvpn-status.log
```

**Revoke access:**
```bash
# WireGuard - Remove peer from config
sudo nano /etc/wireguard/wg0.conf
# Delete [Peer] section
sudo systemctl restart wg-quick@wg0

# OpenVPN - Revoke certificate
cd /etc/openvpn/easy-rsa
./easyrsa revoke client_name
./easyrsa gen-crl
```

### Suspected Compromise

**Immediate actions:**
```bash
# 1. Stop all VPN services
sudo systemctl stop wg-quick@wg0
sudo systemctl stop shadowsocks
sudo systemctl stop openvpn@server

# 2. Block VPN ports
sudo ufw deny 51820/udp
sudo ufw deny 8388/tcp
sudo ufw deny 1194/udp

# 3. Check for suspicious activity
sudo last
sudo lastb
ps aux | grep -E 'wireguard|shadowsocks|openvpn'

# 4. Backup and reinstall if needed
```

## Docker Issues

### Container Won't Start

**Check logs:**
```bash
docker-compose logs SERVICE_NAME
```

**Common fixes:**
```bash
# Remove and recreate
docker-compose down
docker-compose up -d

# Check permissions
sudo chown -R 1000:1000 ./config-directory

# Check ports
sudo netstat -tulpn | grep PORT_NUMBER
```

### Permission Denied

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login again
# Or use sudo
sudo docker-compose up -d
```

## Verification

### Run Verification Script

```bash
cd /root/stealth-vpn-server
chmod +x verify-installation.sh
sudo ./verify-installation.sh
```

### Manual Checks

**1. Service Status:**
```bash
sudo systemctl status wg-quick@wg0
sudo systemctl status shadowsocks
sudo systemctl status openvpn@server
```

**2. Port Listening:**
```bash
sudo netstat -tulpn | grep -E '51820|8388|1194'
```

**3. Firewall:**
```bash
sudo ufw status verbose
```

**4. Logs:**
```bash
sudo journalctl -u wg-quick@wg0 -n 50
sudo journalctl -u shadowsocks -n 50
sudo journalctl -u openvpn@server -n 50
```

## Getting Help

### Collect Information

Before asking for help, collect:

```bash
# System info
uname -a
cat /etc/os-release

# Service status
sudo systemctl status wg-quick@wg0
sudo systemctl status shadowsocks
sudo systemctl status openvpn@server

# Logs
sudo journalctl -u wg-quick@wg0 -n 100 > wireguard.log
sudo journalctl -u shadowsocks -n 100 > shadowsocks.log
sudo journalctl -u openvpn@server -n 100 > openvpn.log

# Network info
ip addr
ip route
sudo iptables -L -n -v
```

### Where to Get Help

1. **GitHub Issues:** https://github.com/kishan7878/stealth-vpn-server/issues
2. **Documentation:** Check all docs in `/docs` folder
3. **Community Forums:**
   - WireGuard: https://lists.zx2c4.com/mailman/listinfo/wireguard
   - OpenVPN: https://forums.openvpn.net
   - Shadowsocks: https://github.com/shadowsocks/shadowsocks/issues

## Common Error Messages

### "Address already in use"
**Solution:** Port is occupied, change port or kill process

### "Permission denied"
**Solution:** Run with sudo or fix file permissions

### "Cannot allocate memory"
**Solution:** Server out of memory, add swap or upgrade

### "Network is unreachable"
**Solution:** Check internet connection and routing

### "Connection refused"
**Solution:** Service not running or firewall blocking

### "Certificate verify failed"
**Solution:** Regenerate certificates or check system time

---

**Still having issues?** Open an issue on GitHub with:
- Detailed description
- Error messages
- System information
- Steps to reproduce
