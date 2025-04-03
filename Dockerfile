FROM linuxserver/jackett:latest

# Set environment variables upfront
ENV JACKETT_ARCH=LinuxAMDx64 \
    XDG_CONFIG_HOME=/config \
    PUID=1000 \
    PGID=1000 \
    TZ=UTC \
    DEBIAN_FRONTEND=noninteractive

# Install dependencies with proper certificate setup
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    libicu70 \
    libssl3 \
    tar \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download and install Jackett with proper SSL handling
RUN mkdir -p /app/Jackett && \
    JACKETT_RELEASE=$(curl -s https://api.github.com/repos/Jackett/Jackett/releases/latest | jq -r '.tag_name') && \
    curl -k -o /tmp/jacket.tar.gz -L \
    "https://github.com/Jackett/Jackett/releases/download/${JACKETT_RELEASE}/Jackett.Binaries.${JACKETT_ARCH}.tar.gz" && \
    tar xf /tmp/jacket.tar.gz -C /app/Jackett --strip-components=1 && \
    chmod -R 755 /app/Jackett && \
    rm -rf /tmp/*

# Create a non-root user and set permissions
RUN groupadd -g ${PGID} jackett && \
    useradd -u ${PUID} -g jackett -d /app jackett && \
    chown -R jackett:jackett /app /config

# Expose port and set volume
EXPOSE 9117
VOLUME /config

# Run as non-root user
USER jackett
WORKDIR /app/Jackett

# Entrypoint
CMD ["./jackett", "--NoUpdates"]
