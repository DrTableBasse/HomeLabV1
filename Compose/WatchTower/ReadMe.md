# Watchtower avec Docker Compose

## Présentation de l'outil Watchtower

Watchtower est un outil qui permet de mettre à jour automatiquement les conteneurs Docker lorsqu'une nouvelle image est disponible. Cela est particulièrement utile pour maintenir vos services à jour sans intervention manuelle.

## Avantages de Watchtower

- **Automatisation** : Met à jour automatiquement les conteneurs Docker.
- **Sécurité** : Assure que les conteneurs utilisent les dernières versions des images, incluant les correctifs de sécurité.
- **Simplicité** : Facile à configurer et à utiliser avec Docker Compose.

## Utilisation avec Docker Compose

Voici un exemple de fichier `docker-compose.yml` pour utiliser Watchtower :

```yaml
services:
  watchtower:
    image: containrrr/watchtower:latest
    container_name: watchtower
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Paris
      - WATCHTOWER_POLL_INTERVAL=604800
      - WATCHTOWER_CLEANUP=true
      - WATCHTOWER_INCLUDE_STOPPED=true
      - WATCHTOWER_REVIVE_STOPPED=false
      - WATCHTOWER_NOTIFICATIONS=shoutrrr
      - WATCHTOWER_NOTIFICATION_URL=discord://token@idWebhook #envoyer des notification sur discord
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    network_mode: host
    restart: unless-stopped
```

## Configuration

- **WATCHTOWER_CLEANUP** : Supprime les anciennes images après la mise à jour.
- **WATCHTOWER_POLL_INTERVAL** : Intervalle de temps (en secondes) entre les vérifications des mises à jour.

## Démarrage

Pour démarrer Watchtower avec Docker Compose, utilisez la commande suivante :

```sh
docker-compose up -d
```

Cela lancera Watchtower en arrière-plan et commencera à surveiller les mises à jour des conteneurs.




## Exemple de notification sur Discord

![alt text](image.png)

## Exemple de logs de Watchtower

On sait ici que tout fonctionne comme il faut 😁

```sh
watchtower  | time="2024-10-26T11:50:07+02:00" level=info msg="Watchtower 1.7.1"
watchtower  | time="2024-10-26T11:50:07+02:00" level=info msg="Using notifications: discord"
watchtower  | time="2024-10-26T11:50:07+02:00" level=info msg="Checking all containers (except explicitly disabled with label)"
watchtower  | time="2024-10-26T11:50:07+02:00" level=info msg="Scheduling first run: 2024-10-26 11:50:37 +0200 CEST"
watchtower  | time="2024-10-26T11:50:07+02:00" level=info msg="Note that the first check will be performed in 29 seconds"
watchtower  | time="2024-10-26T11:50:49+02:00" level=info msg="Found new linuxserver/qbittorrent:latest image (6c3b6525afc6)"
watchtower  | time="2024-10-26T11:51:03+02:00" level=info msg="Found new lscr.io/linuxserver/sonarr:latest image (c709862c93ab)"
watchtower  | time="2024-10-26T11:51:15+02:00" level=info msg="Found new lscr.io/linuxserver/radarr:latest image (8e0c38c89940)"
watchtower  | time="2024-10-26T11:51:25+02:00" level=info msg="Found new lscr.io/linuxserver/prowlarr:latest image (5e33f5354db2)"
watchtower  | time="2024-10-26T11:51:34+02:00" level=info msg="Found new vaultwarden/server:latest image (132bbed157fd)"
watchtower  | time="2024-10-26T11:51:34+02:00" level=info msg="Stopping /prowlarr (712adc31b10c) with SIGTERM"
watchtower  | time="2024-10-26T11:51:38+02:00" level=info msg="Stopping /radarr (1c705d00a911) with SIGTERM"
watchtower  | time="2024-10-26T11:51:42+02:00" level=info msg="Stopping /sonarr (8cb182770c3a) with SIGTERM"
```

## Next Step

- Monitorer dans Grafana les logs et faire de jolies dashboard.