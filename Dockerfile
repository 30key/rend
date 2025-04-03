FROM linuxserver/jackett:latest

ARG JACKETT_VERSION=latest
ARG USER_ID=1000
ARG GROUP_ID=1000

ENV PUID=${USER_ID}
ENV PGID=${GROUP_ID}
ENV TZ=UTC
ENV AUTO_UPDATE=true
ENV RUN_OPTS="--NoUpdates"

# Install any additional dependencies if needed
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    unzip && \
    rm -rf /var/lib/apt/lists/*

# Add custom scripts
COPY scripts/ /custom-scripts/
RUN chmod +x /custom-scripts/*.sh

# Entrypoint wrapper
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9117
VOLUME ["/config", "/downloads"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/init"]
