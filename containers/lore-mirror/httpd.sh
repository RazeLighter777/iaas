#!/bin/bash
# Serve the public-inbox web UI once the mirror container has initialized the
# first inbox. public-inbox-httpd snapshots its config at startup, so watch
# the config file and SIGHUP the daemon when the mirror adds new inboxes.
set -u

LISTEN=${LISTEN:-0.0.0.0:8080}
CONFIG="${HOME}/.public-inbox/config"

until [ -s "${CONFIG}" ]; do
    echo "Waiting for public-inbox config at ${CONFIG} (initial mirror still running)"
    sleep 30
done

public-inbox-httpd -l "${LISTEN}" &
pid=$!
trap 'kill -TERM ${pid} 2>/dev/null' TERM INT

last=$(stat -c %Y "${CONFIG}")
while kill -0 "${pid}" 2>/dev/null; do
    sleep 60
    cur=$(stat -c %Y "${CONFIG}" 2>/dev/null || echo "${last}")
    if [ "${cur}" != "${last}" ]; then
        last=${cur}
        echo "public-inbox config changed; reloading httpd"
        kill -HUP "${pid}"
    fi
done
wait "${pid}"
