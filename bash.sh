# Build with custom arguments
docker build \
  --build-arg USER_ID=1001 \
  --build-arg GROUP_ID=1001 \
  -t custom-jackett .

# Run with custom volumes
docker run -d \
  --name=custom-jackett \
  -p 9117:9117 \
  -v jackett_config:/config \
  -v jackett_downloads:/downloads \
  -v /path/to/custom-indexers:/custom-indexers \
  custom-jackett
