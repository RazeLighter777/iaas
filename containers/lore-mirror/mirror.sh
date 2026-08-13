#!/bin/bash
# Continuously mirror lkml git epochs from lore.kernel.org with grok-pull
# (one-shot mode, looped here so indexing runs between pulls), then
# (re)index them into the public-inbox database.
set -u

TOPLEVEL=/data/git
INBOX_DIR=${TOPLEVEL}/lkml
INBOX_URL=${INBOX_URL:-https://lore.example.com/lkml}
INBOX_ADDRESS=${INBOX_ADDRESS:-linux-kernel@vger.kernel.org}
INBOX_NEWSGROUP=${INBOX_NEWSGROUP:-org.kernel.vger.linux-kernel}
INBOX_LISTID=${INBOX_LISTID:-linux-kernel.vger.kernel.org}
REFRESH_SECONDS=${REFRESH_SECONDS:-300}
INDEX_JOBS=${INDEX_JOBS:-2}
INDEX_LEVEL=${INDEX_LEVEL:-full}
INDEX_BATCH_SIZE=${INDEX_BATCH_SIZE:-10m}
PI_CONFIG_FILE="${HOME}/.public-inbox/config"

mkdir -p "${TOPLEVEL}" "${HOME}"

while true; do
    grok-pull -v -c /etc/lore-mirror/grokmirror.conf
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "grok-pull exited with ${rc}; retrying in ${REFRESH_SECONDS}s" >&2
    fi

    if [ -d "${INBOX_DIR}/git/0.git" ]; then
        if ! git config -f "${PI_CONFIG_FILE}" --get publicinbox.lkml.inboxdir >/dev/null 2>&1; then
            echo "Initializing public-inbox for lkml"
            public-inbox-init -V2 -L "${INDEX_LEVEL}" --ng "${INBOX_NEWSGROUP}" \
                lkml "${INBOX_DIR}" "${INBOX_URL}" "${INBOX_ADDRESS}" \
            && git config -f "${PI_CONFIG_FILE}" publicinbox.lkml.listid "${INBOX_LISTID}"
        fi
        public-inbox-index --no-fsync -j "${INDEX_JOBS}" \
            --batch-size "${INDEX_BATCH_SIZE}" "${INBOX_DIR}"
    else
        echo "lkml epoch 0 not yet cloned; skipping index"
    fi

    sleep "${REFRESH_SECONDS}"
done
