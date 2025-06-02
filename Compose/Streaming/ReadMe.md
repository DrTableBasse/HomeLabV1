# 📦 Homelab Docker Stack – Media & VPN

This Docker Compose stack sets up a privacy-focused media downloading and management system using a VPN tunnel. It includes torrenting apps, indexers, media managers, and a few support services.

---

## 🧠 Table of Contents

- [🗂️ Schema of the stack](#-schéma-du-stack)
- [🛡️ VPN - Gluetun](#-vpn---gluetun)
- [🧠 Flaresolverr](#-flaresolverr)
- [🍿 Jellyseerr](#-jellyseerr)
- [🎭 Joal](#-joal)
- [🌊 qBittorrent](#-qbittorrent)
- [📡 Prowlarr](#-prowlarr)
- [📺 Sonarr](#-sonarr)
- [🎬 Radarr](#-radarr)
- [🌐 Networks](#-networks)

---


## 🗂️ Schema of the stack

![alt text](src/img/Diagram.png)

## 🛡️ VPN - Gluetun

Routes all traffic from `qbittorrent` and `joal` through a secure ProtonVPN connection using OpenVPN.

```yaml
container_name: gluetun_vpn
image: qmcgaw/gluetun:v3.39.0 #Ill do some test with the last version later
cap_add:
  - net_admin
environment:
  - VPN_SERVICE_PROVIDER=protonvpn
  - OPENVPN_USER=+pmp+nr
  - OPENVPN_PASSWORD=
  - SERVER_COUNTRIES=Netherlands,Germany
ports:
  - 8112:8112
  - 6881:6881
  - 6881:6881/udp
  - 8114:8114
restart: unless-stopped
```

**Purpose**:
- Tunnels all traffic via ProtonVPN for anonymity.
- Necessary for `qbittorrent` and `joal` to function through the VPN.

---

## 🧠 Flaresolverr

Bypasses Cloudflare protection mechanisms for indexers that require it.

```yaml
image: 21hsmw/flaresolverr:nodriver
container_name: flaresolverr
environment:
  - LOG_LEVEL=info
  - LOG_HTML=false
  - CAPTCHA_SOLVER=none
  - TZ=Europe/London
ports:
  - 8191:8191
restart: unless-stopped
```

**Purpose**:
- Used by indexers like Prowlarr to bypass Cloudflare checks when scraping.

---

## 🍿 Jellyseerr

A fork of Overseerr with enhanced features for requesting and managing content.

```yaml
image: fallenbagel/jellyseerr:latest
container_name: jellyseerr
environment:
  - LOG_LEVEL=debug
  - TZ=Asia/Tashkent
  - PORT=5055
ports:
  - 5055:5055
volumes:
  - ./jellyseerr/config:/app/config
restart: unless-stopped
```

**Purpose**:
- Users request movies and TV shows to be downloaded.
- Interfaces with Radarr and Sonarr.

---

## 🎭 Joal (Jack of All Leechers)

A ratio faking client that emulates a torrent client to seed fake data.
I do not recommend using this client, as it can lead to account bans on private trackers.

```yaml
image: anthonyraymond/joal
container_name: joal
restart: unless-stopped
volumes:
  - ./config:/data
environment:
  - TZ=Europe/Paris
command:
  [
    "--joal-conf=/data",
    "--spring.main.web-environment=true",
    "--server.port=8114",
    "--joal.ui.path.prefix=SECRET_OBFUSCATION_PATH", #Dont need to change this, just use the default
    "--joal.ui.secret-token=SECRET_TOKEN" #Dont need to change this, just use the default
  ]
network_mode: "service:vpn"
```

**Purpose**:
- Helps maintain a good ratio on private torrent trackers.
- Routes traffic through Gluetun VPN.

---

## 🌊 qBittorrent

Torrent download client with a built-in web UI.

```yaml
container_name: qbittorrent
image: linuxserver/qbittorrent:latest
restart: unless-stopped
network_mode: service:vpn
environment:
  - PUID=1000
  - PGID=1000
  - TZ=Europe/Paris
  - WEBUI_PORT=8112
volumes:
  - ./qbittorrent/config:/config
  - /mnt/Disk/jellyfin/downloads:/downloads
```

**Purpose**:
- Downloads torrents securely over VPN.
- Configurable via web UI (port 8112).

---

## 📡 Prowlarr

Indexer manager that connects to various torrent trackers.

```yaml
image: lscr.io/linuxserver/prowlarr:latest
container_name: prowlarr
environment:
  - PUID=1000
  - PGID=1000
  - TZ=Europe/London
volumes:
  - ./Prowlarr/Config:/config
  - ./Prowlarr/Backup:/data/Backup
  - /mnt/Disk/jellyfin/downloads:/data/downloads
ports:
  - 9697:9696
restart: unless-stopped
networks:
  - arrs
```

**Purpose**:
- Indexer for Radarr and Sonarr.
- Supports multiple indexers (torrent and usenet).

---

## 📺 Sonarr

TV show manager that works with Prowlarr and qBittorrent.

```yaml
image: lscr.io/linuxserver/sonarr:latest
container_name: sonarr
environment:
  - PUID=1000
  - PGID=1000
  - TZ=Europe/London
volumes:
  - ./Sonarr/Config:/config
  - ./Sonarr/Backup:/data/Backup
  - /mnt/Disk/jellyfin:/data/tvshows
  - /mnt/Disk/jellyfin/downloads:/data/downloads
ports:
  - 8989:8989
restart: unless-stopped
networks:
  - arrs
```

**Purpose**:
- Automates downloading, renaming, and organizing TV shows.

---

## 🎬 Radarr

Movie manager similar to Sonarr but for films.

```yaml
image: lscr.io/linuxserver/radarr:latest
container_name: radarr
environment:
  - PUID=1000
  - PGID=1000
  - TZ=Europe/London
volumes:
  - ./Radarr/Config:/config
  - /mnt/Disk/jellyfin/Films-Triés:/data/movies
  - /mnt/Disk/jellyfin/downloads:/data/downloads
  - ./Radarr/Backup:/data/Backup
ports:
  - 7878:7878
restart: unless-stopped
networks:
  - arrs
```

**Purpose**:
- Automates the download and organization of movies.

---

## 🌐 Networks

Defines Docker networks: `arrs` for media apps and `vpn` for services routed via VPN.

```yaml
networks:
  arrs:
    driver: bridge
    ipam:
      config:
        - subnet: 172.16.0.0/16
          gateway: 172.16.0.1
  vpn:
    driver: bridge
```