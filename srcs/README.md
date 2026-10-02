*This project has been created as part of the 42 curriculum by daniefe2.*

# Inception

## Description

Inception is a Docker-based infrastructure project built with Docker Compose.

The goal is to run a small WordPress website using three dedicated services:

- NGINX: HTTPS reverse proxy and web server.
- WordPress: PHP-FPM application server.
- MariaDB: WordPress database server.

Each service is built from its own Dockerfile using Debian Bookworm-slim. The services communicate through a private Docker network. NGINX is the only service exposed to the host through HTTPS on port 443.

The project includes:

- Automatic MariaDB initialization.
- Automatic WordPress installation.
- TLS 1.2 and TLS 1.3.
- Docker secrets for passwords.
- Persistent named volumes.
- A Makefile for project management.
- WordPress administrator and editor users.

## Instructions

### Requirements

- Docker Engine
- Docker Compose
- GNU Make

Clone the repository and enter the project directory:

    git clone <repository-url>
    cd inception

Build and start the project:

    make build
    make up

The website is available at:

    https://daniefe2.42.fr

Useful commands:

    make status
    make logs
    make logs-follow
    make restart
    make down
    make config
    make tree
    make secret-tree

## Data Persistence

Persistent data is stored on the host:

    /home/daniefe2/data/mariadb
    /home/daniefe2/data/wordpress

These directories must not be deleted before evaluation.

## Project Structure

    .
    |-- Makefile
    |-- README.md
    |-- secrets/
    `-- srcs/
        |-- docker-compose.yml
        |-- .env
        `-- requirements/
            |-- mariadb/
            |-- nginx/
            `-- wordpress/

## References

- Docker Engine Documentation:
  https://docs.docker.com/engine/

- Docker Compose Documentation:
  https://docs.docker.com/compose/

- Dockerfile Reference:
  https://docs.docker.com/reference/dockerfile/

- Docker Volumes Documentation:
  https://docs.docker.com/engine/storage/volumes/

- Docker Secrets Documentation:
  https://docs.docker.com/engine/swarm/secrets/

Additional help and feedback were obtained through discussions, peer reviews, and troubleshooting sessions with fellow 42 students.
