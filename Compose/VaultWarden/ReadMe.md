# VaultWarden

VaultWarden (formerly known as Bitwarden_RS) is an unofficial Bitwarden server implementation written in Rust. It is a lightweight and efficient alternative to the official Bitwarden server.

## Installation with Docker Compose

To install VaultWarden using Docker Compose, follow these steps:

1. **Create a Docker Compose file**: Create a `docker-compose.yml` file in your desired directory with the following content:

    ```yaml
    version: "3"
    services:
    vaultwarden:
        image: vaultwarden/server:latest
        container_name: vaultwarden
        restart: unless-stopped
        ports:
        - 9445:80 #map any custom port to use (replace 9445 not 80)
        volumes:
        - ./bitwarden:/data:rw
        environment:
        #     - ROCKET_TLS={certs="/ssl/certs/certs.pem",key="/ssl/private/key.pem"}  // Environment variable is specific to the Rocket web server
        - ADMIN_TOKEN=${ADMIN_TOKEN}
        - WEBSOCKET_ENABLED=true
        - SIGNUPS_ALLOWED=false
        - SMTP_HOST=${SMTP_HOST}
        - SMTP_FROM=${SMTP_FROM}
        - SMTP_PORT=${SMTP_PORT}
        - SMTP_SSL=${SMTP_SSL}
        - SMTP_USERNAME=${SMTP_USERNAME}
        - SMTP_PASSWORD=${SMTP_PASSWORD}
        - DOMAIN=${DOMAIN}

        networks:
        - npm_default

    networks:
    npm_default:
        external: true
    ```

2. **Set up environment variables**: Replace `your_admin_token` with a secure token for accessing the admin panel.

3. **Create a data directory**: Ensure that the `vw-data` directory exists in the same directory as your `docker-compose.yml` file. This directory will be used to store VaultWarden data.

4. **Start the services**: Run the following command to start VaultWarden:

    ```sh
    docker-compose up -d
    ```

5. **Access VaultWarden**: Open your web browser and navigate to `http://localhost` to access your VaultWarden instance.

6. **Admin Panel**: To access the admin panel, navigate to `http://localhost/admin` and use the admin token you set in the `docker-compose.yml` file.

## Additional Configuration

You can customize your VaultWarden setup by adding more environment variables to the `docker-compose.yml` file. Refer to the [VaultWarden documentation](https://github.com/dani-garcia/vaultwarden/wiki) for more details.

#### Note:
You must access, in first time, to the set parameters for SMTP, DOMAIN, etc. in the admin panel (IP/admin or FQDN/admin) and lock the creation of other accounts.