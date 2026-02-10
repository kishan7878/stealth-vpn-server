# 🐳 Docker Deployment Guide

Deploy your VPN server using Docker for easy management and portability.

## Prerequisites

- Docker installed
- Docker Compose installed
- Root access

## Quick Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

## Deployment Options

### Option 1: WireGuard with Web UI (Easiest)

```bash
# Clone repository
git clone https://github.com/kishan7878/stealth-vpn-server.git
cd stealth-vpn-server

# Configure environment
cp .env.example .env
nano .env  # Update SERVER_IP and passwords

# Start WireGuard with web UI
docker-compose up -d wg-easy

# Access web UI
# Open browser: http://YOUR_SERVER_IP:51821
# Login with password from .env file
```

**Features:**
- ✅ Web-based management
- ✅ QR codes for mobile
- ✅ Easy client management
- ✅ No command line needed

### Option 2: All VPN Protocols

```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### Option 3: Individual Services

```bash
# WireGuard only
docker-compose up -d wireguard

# Shadowsocks only
docker-compose up -d shadowsocks

# OpenVPN only
docker-compose up -d openvpn
```

## Configuration

### WireGuard Web UI

1. Access: `http://YOUR_SERVER_IP:51821`
2. Login with password from `.env`
3. Click "Add Client"
4. Scan QR code or download config

### Shadowsocks

```bash
# Get connection details
docker-compose logs shadowsocks

# Connection info:
# Server: YOUR_SERVER_IP
# Port: 8388
# Password: From .env file
# Method: chacha20-ietf-poly1305
```

### OpenVPN

```bash
# Initialize OpenVPN
docker-compose run --rm openvpn ovpn_genconfig -u udp://YOUR_SERVER_IP
docker-compose run --rm openvpn ovpn_initpki

# Generate client config
docker-compose run --rm openvpn easyrsa build-client-full client1 nopass
docker-compose run --rm openvpn ovpn_getclient client1 > client1.ovpn
```

## Management Commands

### Start/Stop Services

```bash
# Start all
docker-compose up -d

# Stop all
docker-compose down

# Restart specific service
docker-compose restart wireguard
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f wireguard
docker-compose logs -f shadowsocks
```

### Update Services

```bash
# Pull latest images
docker-compose pull

# Restart with new images
docker-compose up -d
```

## Client Configuration

### WireGuard
1. Open web UI: `http://YOUR_SERVER_IP:51821`
2. Create new client
3. Download config or scan QR code

### Shadowsocks
Create connection URL:
```
ss://METHOD:PASSWORD@SERVER_IP:PORT
```

Example:
```
ss://chacha20-ietf-poly1305:MyPassword123@1.2.3.4:8388
```

### OpenVPN
```bash
# Generate client config
docker-compose run --rm openvpn easyrsa build-client-full CLIENT_NAME nopass
docker-compose run --rm openvpn ovpn_getclient CLIENT_NAME > CLIENT_NAME.ovpn
```

## Firewall Configuration

```bash
# Allow VPN ports
sudo ufw allow 51820/udp  # WireGuard
sudo ufw allow 51821/tcp  # WireGuard Web UI
sudo ufw allow 8388/tcp   # Shadowsocks
sudo ufw allow 8388/udp   # Shadowsocks
sudo ufw allow 1194/udp   # OpenVPN
```

## Backup Configuration

```bash
# Backup all configs
tar -czf vpn-backup-$(date +%Y%m%d).tar.gz \
  wireguard-config/ \
  wg-easy-data/ \
  openvpn-data/ \
  .env

# Restore from backup
tar -xzf vpn-backup-YYYYMMDD.tar.gz
docker-compose up -d
```

## Monitoring

### Check Service Health

```bash
# Container status
docker-compose ps

# Resource usage
docker stats

# Network connections
docker-compose exec wireguard wg show
```

### Performance Monitoring

```bash
# Install monitoring stack (optional)
docker run -d \
  --name=netdata \
  -p 19999:19999 \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  netdata/netdata

# Access: http://YOUR_SERVER_IP:19999
```

## Troubleshooting

### Service won't start

```bash
# Check logs
docker-compose logs SERVICE_NAME

# Check permissions
sudo chown -R 1000:1000 ./wireguard-config
sudo chown -R 1000:1000 ./wg-easy-data
```

### Can't connect to VPN

```bash
# Verify ports are open
sudo netstat -tulpn | grep -E '51820|8388|1194'

# Check firewall
sudo ufw status

# Restart services
docker-compose restart
```

### Reset everything

```bash
# Stop and remove all
docker-compose down -v

# Remove data
sudo rm -rf wireguard-config/ wg-easy-data/ openvpn-data/

# Start fresh
docker-compose up -d
```

## Advanced Configuration

### Custom DNS

Edit `docker-compose.yml`:
```yaml
environment:
  - PEERDNS=1.1.1.1,9.9.9.9  # Cloudflare + Quad9
```

### Multiple Ports

```yaml
ports:
  - "51820:51820/udp"
  - "51821:51821/udp"  # Additional port
```

### Resource Limits

```yaml
services:
  wireguard:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
```

## Security Best Practices

1. **Change default passwords** in `.env`
2. **Use strong encryption** (already configured)
3. **Regular updates:**
   ```bash
   docker-compose pull
   docker-compose up -d
   ```
4. **Limit web UI access:**
   ```bash
   # Only allow from specific IP
   sudo ufw allow from YOUR_IP to any port 51821
   ```
5. **Enable automatic updates:**
   ```bash
   # Install watchtower
   docker run -d \
     --name watchtower \
     -v /var/run/docker.sock:/var/run/docker.sock \
     containrrr/watchtower
   ```

## Cost Optimization

- **Shared hosting:** Run all protocols on one server
- **Resource limits:** Prevent excessive usage
- **Monitoring:** Track bandwidth usage
- **Auto-scaling:** Use cloud provider auto-scaling

## Migration

### Export Configuration

```bash
# Backup everything
docker-compose down
tar -czf vpn-complete-backup.tar.gz .
```

### Import to New Server

```bash
# On new server
scp vpn-complete-backup.tar.gz root@NEW_SERVER:/root/
ssh root@NEW_SERVER
tar -xzf vpn-complete-backup.tar.gz
docker-compose up -d
```

## Next Steps

- [Performance Tuning](./performance.md)
- [Multi-Server Setup](./multi-server.md)
- [Monitoring Guide](./monitoring.md)

---

**Deployment time:** 5 minutes  
**Maintenance:** Minimal  
**Scalability:** Excellent
