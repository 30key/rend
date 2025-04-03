#!/bin/bash
set -e

# Run custom pre-start scripts
for script in /custom-scripts/*.sh; do
    if [ -f "$script" ]; then
        echo "Running custom script: $script"
        bash "$script"
    fi
done

# Execute the original entrypoint
exec /init "$@"
