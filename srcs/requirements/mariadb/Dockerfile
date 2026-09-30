# Base image: Debian "bookworm" = penultimate stable release
# (trixie is current stable, bookworm is the one before it)
FROM debian:bookworm-slim

# Install MariaDB server + client
# --no-install-recommends keeps the image lean (optional but good practice)
# rm -rf .../apt/lists/* clears the package cache to reduce image size
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN rm -rf /var/lib/mysql/*
# Copy our custom MariaDB config (overrides default bind-address etc.)
COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy our startup/init script and make it executable
COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh

# Document that this container listens on MariaDB's default port
# (EXPOSE is informational only, does not actually publish the port -
# the docker-compose network handles real connectivity)
EXPOSE 3306

# ENTRYPOINT defines what runs when the container starts.
# Using our init script here so it can set up the DB on first run,
# then hand off to mysqld as PID 1 (see script itself for details)
ENTRYPOINT ["/usr/local/bin/init_db.sh"]
