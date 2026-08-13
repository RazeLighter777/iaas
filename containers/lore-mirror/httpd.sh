#!/bin/bash
# Serve the public-inbox web UI once the mirror container has initialized the inbox.
set -u

LISTEN=${LISTEN:-0.0.0.0:8080}
CONFIG="${HOME}/.public-inbox/config"

until [ -s "${CONFIG}" ]; do
    echo "Waiting for public-inbox config at ${CONFIG} (initial mirror still running)"
    sleep 30
done

exec public-inbox-httpd -l "${LISTEN}"
