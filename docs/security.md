# 🔒 Security Best Practices

## Server Hardening

### 1. SSH Security

```bash
# Disable password authentication
sudo nano /etc/ssh/sshd_config

# Set these values:
PasswordAuthentication no
PermitRootLogin prohibit-password
PubkeyAuthentication yes

# Restart SSH
sudo systemctl restart sshd
```

### 2. Firewall Configuration

```bash
# Install UFW
sudo apt install ufw

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH
sudo ufw allow 22/tcp

# Allow VPN ports
sudo ufw allow 51820/udp  # WireGuard
sudo ufw allow 8388/tcp   # Shadowsocks
sudo ufw allow 1194/udp   # OpenVPN

# Enable firewall
sudo ufw enable
```

### 3. Fail2Ban

```bash
# Install Fail2Ban
sudo apt install fail2ban

# Configure
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local

# Add VPN protection
[wireguard]
enabled = true
port = 51820
protocol = udp
filter = wireguard
logpath = /var/log/syslog
maxretry = 3

# Start service
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 4. Automatic Updates

```bash
# Install unattended-upgrades
sudo apt install unattended-upgrades

# Configure
sudo dpkg-reconfigure -plow unattended-upgrades

# Enable automatic security updates
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades

# Uncomment:
"${distro_id}:${distro_codename}-security";
```

## VPN Security

### 1. Strong Encryption

All our configurations use:
- **WireGuard:** ChaCha20-Poly1305
- **Shadowsocks:** ChaCha20-IETF-Poly1305
- **OpenVPN:** AES-256-GCM with SHA512

### 2. DNS Leak Protection

```bash
# WireGuard - Already configured
DNS = 1.1.1.1, 8.8.8.8

# Test for leaks
# Visit: https://dnsleaktest.com
```

### 3. Kill Switch

#### WireGuard Kill Switch
```bash
# Add to client config
PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
PreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
```

#### OpenVPN Kill Switch
```bash
# Add to client config
pull-filter ignore "redirect-gateway"
route-nopull
route 0.0.0.0 0.0.0.0 vpn_gateway
```

### 4. Perfect Forward Secrecy

All protocols support PFS:
- **WireGuard:** Built-in key rotation
- **OpenVPN:** Configured with TLS-Auth
- **Shadowsocks:** Session-based encryption

## Privacy Protection

### 1. No Logging Policy

```bash
# Disable logging (optional, for privacy)
# WireGuard
sudo systemctl stop systemd-journald
sudo systemctl disable systemd-journald

# Or limit log retention
sudo journalctl --vacuum-time=1d
```

### 2. Traffic Obfuscation

#### Shadowsocks with V2Ray Plugin
```bash
# Install v2ray-plugin
wget https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.2/v2ray-plugin-linux-amd64-v1.3.2.tar.gz
tar -xzf v2ray-plugin-linux-amd64-v1.3.2.tar.gz
sudo mv v2ray-plugin_linux_amd64 /usr/local/bin/v2ray-plugin

# Update Shadowsocks config
{
    "server": "0.0.0.0",
    "server_port": 443,
    "password": "your_password",
    "method": "chacha20-ietf-poly1305",
    "plugin": "v2ray-plugin",
    "plugin_opts": "server;tls;host=yourdomain.com"
}
```

### 3. Multi-Hop VPN

```bash
# Chain VPNs for extra privacy
# Connect to VPN1 -> Connect to VPN2
# Your traffic: You -> VPN1 -> VPN2 -> Internet
```

## Monitoring & Alerts

### 1. Connection Monitoring

```bash
# WireGuard status
sudo wg show

# Active connections
sudo wg show wg0 peers

# Transfer stats
sudo wg show wg0 transfer
```

### 2. Intrusion Detection

```bash
# Install AIDE
sudo apt install aide

# Initialize database
sudo aideinit

# Check for changes
sudo aide --check
```

### 3. Log Monitoring

```bash
# Real-time log monitoring
sudo tail -f /var/log/syslog | grep -E 'wireguard|shadowsocks|openvpn'

# Failed connection attempts
sudo journalctl -u wg-quick@wg0 | grep -i fail
```

## Advanced Security

### 1. Port Knocking

```bash
# Install knockd
sudo apt install knockd

# Configure
sudo nano /etc/knockd.conf

[openSSH]
    sequence    = 7000,8000,9000
    seq_timeout = 5
    command     = /sbin/iptables -A INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
    tcpflags    = syn

[closeSSH]
    sequence    = 9000,8000,7000
    seq_timeout = 5
    command     = /sbin/iptables -D INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
    tcpflags    = syn
```

### 2. Two-Factor Authentication

```bash
# Install Google Authenticator
sudo apt install libpam-google-authenticator

# Setup for user
google-authenticator

# Configure SSH
sudo nano /etc/pam.d/sshd
# Add: auth required pam_google_authenticator.so

# Enable in SSH config
sudo nano /etc/sshd_config
# Set: ChallengeResponseAuthentication yes
```

### 3. IP Whitelisting

```bash
# Allow only specific IPs
sudo ufw delete allow 22
sudo ufw allow from YOUR_IP to any port 22

# For VPN management
sudo ufw allow from YOUR_IP to any port 51821  # WireGuard UI
```

## Compliance & Legal

### 1. Data Retention

```bash
# Minimal logging for compliance
# Keep only essential connection logs
# Rotate logs frequently
sudo nano /etc/logrotate.d/vpn

/var/log/vpn/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}
```

### 2. Terms of Service

Create a TOS for your VPN:
- No illegal activities
- No spam/abuse
- Bandwidth limits
- Privacy policy
- Logging policy

### 3. GDPR Compliance

If serving EU users:
- Minimal data collection
- Clear privacy policy
- User data deletion on request
- Secure data storage

## Incident Response

### 1. Compromise Detection

```bash
# Check for unauthorized access
sudo last
sudo lastb

# Check running processes
ps aux | grep -E 'wireguard|shadowsocks|openvpn'

# Check open ports
sudo netstat -tulpn
```

### 2. Emergency Shutdown

```bash
# Stop all VPN services
sudo systemctl stop wg-quick@wg0
sudo systemctl stop shadowsocks
sudo systemctl stop openvpn@server

# Block all VPN ports
sudo ufw deny 51820/udp
sudo ufw deny 8388/tcp
sudo ufw deny 1194/udp
```

### 3. Recovery

```bash
# Backup current state
sudo tar -czf vpn-backup-emergency.tar.gz /etc/wireguard /etc/shadowsocks /etc/openvpn

# Restore from clean backup
sudo systemctl stop wg-quick@wg0
sudo rm -rf /etc/wireguard/*
sudo tar -xzf vpn-backup-clean.tar.gz -C /
sudo systemctl start wg-quick@wg0
```

## Security Checklist

- [ ] SSH key authentication only
- [ ] Firewall configured and enabled
- [ ] Fail2Ban installed and configured
- [ ] Automatic security updates enabled
- [ ] Strong VPN passwords/keys
- [ ] DNS leak protection verified
- [ ] Kill switch configured
- [ ] Logs monitored regularly
- [ ] Backups automated
- [ ] Intrusion detection active
- [ ] Port knocking (optional)
- [ ] 2FA enabled (optional)
- [ ] Regular security audits

## Security Testing

### 1. VPN Leak Tests

- https://ipleak.net
- https://dnsleaktest.com
- https://www.doileak.com
- https://browserleaks.com

### 2. Speed Tests

- https://fast.com
- https://speedtest.net
- https://librespeed.org

### 3. Security Audits

```bash
# Run security audit
sudo apt install lynis
sudo lynis audit system

# Check for vulnerabilities
sudo apt install debsecan
sudo debsecan
```

## Resources

- [WireGuard Security](https://www.wireguard.com/papers/wireguard.pdf)
- [Shadowsocks Security](https://shadowsocks.org/en/spec/Protocol.html)
- [OpenVPN Security](https://openvpn.net/community-resources/hardening-openvpn-security/)
- [OWASP VPN Guide](https://owasp.org/www-community/controls/VPN)

---

**Remember:** Security is an ongoing process, not a one-time setup!
