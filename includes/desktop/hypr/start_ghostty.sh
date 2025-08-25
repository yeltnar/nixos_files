#!/bin/bash

# A simple script to wait for PipeWire to start before launching Ghostty
#
# do I want to use ghostty & or na?

# Max wait time in seconds to prevent an infinite loop
MAX_WAIT_TIME=10
CURRENT_TIME=0

# Loop until the pipewire service is active or max wait time is reached
while [ "$CURRENT_TIME" -lt "$MAX_WAIT_TIME" ]; do
    if systemctl --user is-active --quiet pipewire.service; then
        echo "PipeWire is running. Starting Ghostty..."
        ghostty &
        exit 0
    fi
    echo "Waiting for PipeWire... ($CURRENT_TIME/$MAX_WAIT_TIME)"
    sleep 1
    CURRENT_TIME=$((CURRENT_TIME+1))
done

echo "Timeout reached. PipeWire not found. Starting Ghostty anyway."
ghostty &
exit 1
