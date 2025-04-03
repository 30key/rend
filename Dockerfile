FROM ubuntu:20.04

# Set environment variables
ENV JACKETT_RELEASE=latest \
    JACKETT_ARCH=LinuxAMDx64 \
    XDG_CONFIG_HOME=/config \
    PUID=1000 \
    PGID=1000 \
    TZ=UTC

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libicu66 \
    libssl1.1 \
    wget \
    tar \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install Jackett
RUN mkdir -p /app/Jackett && \
    JACKETT_RELEASE=$(curl -s https://api.github.com/repos/Jackett/Jackett/releases/latest | jq -r '.tag_name') && \
    curl -o /tmp/jacket.tar.gz -L \
    "https://github.com/Jackett/Jackett/releases/download/${JACKETT_RELEASE}/Jackett.Binaries.${JACKETT_ARCH}.tar.gz" && \
    tar xf /tmp/jacket.tar.gz -C /app/Jackett --strip-components=1 && \
    rm -rf /tmp/*

# Set permissions
RUN chown -R ${PUID}:${PGID} /app/Jackett

# Expose port
EXPOSE 9117

# Volume
VOLUME /config

# Run command
CMD ["/app/Jackett/jackett", "--NoUpdates"]
