FROM linuxserver/jackett:latest

# Set environment variables
ENV JACKETT_ARCH=LinuxAMDx64 \
    XDG_CONFIG_HOME=/config \
    PUID=1000 \
    PGID=1000 \
    TZ=UTC \
    DEBIAN_FRONTEND=noninteractive \
    SSL_CERT_DIR=/etc/ssl/certs

# Install minimal dependencies with cleanup in same layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    libicu70 \
    libssl3 && \
    update-ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create user and directories first for better layer caching
RUN groupadd -g ${PGID} jackett && \
    useradd -u ${PUID} -g jackett -d /app jackett && \
    mkdir -p /app/Jackett /config && \
    chown -R jackett:jackett /app /config

# Download and install Jackett as user
USER jackett
WORKDIR /app/Jackett

RUN curl -s https://api.github.com/repos/Jackett/Jackett/releases/latest | \
    jq -r '.tag_name' | \
    xargs -I {} curl -fsSL "https://github.com/Jackett/Jackett/releases/download/{}/Jackett.Binaries.${JACKETT_ARCH}.tar.gz" | \
    tar xz --strip-components=1 && \
    chmod -R 755 /app/Jackett

# Health check (optional but recommended)
HEALTHCHECK --interval=30s --timeout=10s --start-period=1m \
    CMD curl -f http://localhost:9117 || exit 1

# Expose port and set volume
EXPOSE 9117
VOLUME /config

# Entrypoint
ENTRYPOINT ["./jackett"]
CMD ["--NoUpdates"]
