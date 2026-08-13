#!/bin/bash
# Continuously mirror selected lore.kernel.org lists with grok-pull (one-shot
# mode, looped here so indexing runs between pulls), then (re)index each list
# into its public-inbox database. The list set comes from $LISTS.
set -u

TOPLEVEL=/data/git
SITE=${SITE:-https://lore.kernel.org}
LISTS=${LISTS:-lkml}
URL_BASE=${URL_BASE:-https://lore.example.com}
REFRESH_SECONDS=${REFRESH_SECONDS:-300}
INDEX_JOBS=${INDEX_JOBS:-2}
INDEX_LEVEL=${INDEX_LEVEL:-full}
INDEX_BATCH_SIZE=${INDEX_BATCH_SIZE:-10m}
PI_CONFIG_FILE="${HOME}/.public-inbox/config"
GROK_CONF="${HOME}/grokmirror.conf"

mkdir -p "${TOPLEVEL}" "${HOME}"

write_grok_conf() {
    {
        echo "[core]"
        echo "toplevel = ${TOPLEVEL}"
        echo "manifest = ${TOPLEVEL}/manifest.js.gz"
        echo "log = ${TOPLEVEL}/grokmirror.log"
        echo "loglevel = info"
        echo "[remote]"
        echo "site = ${SITE}"
        echo "manifest = ${SITE}/manifest.js.gz"
        echo "[pull]"
        echo "projectslist = ${TOPLEVEL}/projects.list"
        echo "pull_threads = 4"
        first=1
        for l in ${LISTS}; do
            if [ "${first}" = 1 ]; then
                echo "include = /${l}/git/*"
                first=0
            else
                echo "          /${l}/git/*"
            fi
        done
        echo "[fsck]"
        echo "frequency = 30"
        echo "report_to = stdout"
        echo "statusfile = ${TOPLEVEL}/fsck.status.js"
        echo "repair = yes"
    } > "${GROK_CONF}"
}

# Fetch the list's canonical config from lore (address, listid, newsgroup
# differ per list) and initialize its public-inbox. lore serves plain text
# to non-browser user agents (Anubis bot-protection blocks browser UAs).
init_inbox() {
    list=$1
    inboxdir="${TOPLEVEL}/${list}"
    [ -d "${inboxdir}/git/0.git" ] || return 0
    git config -f "${PI_CONFIG_FILE}" --get "publicinbox.${list}.inboxdir" >/dev/null 2>&1 && return 0

    address="" listid="" ng=""
    tmp=$(mktemp)
    if curl -sf -A "lore-mirror/1.0" "${SITE}/${list}/_/text/config/raw" -o "${tmp}"; then
        address=$(git config -f "${tmp}" --get-all "publicinbox.${list}.address" 2>/dev/null | head -1) || true
        listid=$(git config -f "${tmp}" --get "publicinbox.${list}.listid" 2>/dev/null) || true
        ng=$(git config -f "${tmp}" --get "publicinbox.${list}.newsgroup" 2>/dev/null) || true
    fi
    rm -f "${tmp}"
    address=${address:-${list}@vger.kernel.org}

    echo "Initializing public-inbox for ${list} (${address})"
    set -- -V2 -L "${INDEX_LEVEL}"
    [ -n "${ng}" ] && set -- "$@" --ng "${ng}"
    if public-inbox-init "$@" "${list}" "${inboxdir}" "${URL_BASE}/${list}" "${address}"; then
        [ -n "${listid}" ] && git config -f "${PI_CONFIG_FILE}" "publicinbox.${list}.listid" "${listid}"
        git config -f "${PI_CONFIG_FILE}" publicinbox.wwwlisting all
    fi
}

# An unclean shutdown mid-index leaves hot SQLite rollback journals that the
# read-only httpd workers cannot recover (they 500 instead). Recover them by
# briefly opening each database read-write before serving/indexing resumes.
recover_journals() {
    for l in ${LISTS}; do
        for db in "${TOPLEVEL}/${l}/msgmap.sqlite3" \
                  "${TOPLEVEL}/${l}/over.sqlite3" \
                  "${TOPLEVEL}/${l}/xap15/over.sqlite3"; do
            [ -f "${db}-journal" ] || continue
            perl -MDBI -e '
                my $dbh = eval { DBI->connect("dbi:SQLite:dbname=$ARGV[0]", "", "",
                    {RaiseError => 1, sqlite_busy_timeout => 5000}) } or exit 0;
                eval { $dbh->do("BEGIN IMMEDIATE"); $dbh->do("COMMIT") };
                print "recovered journal: $ARGV[0]\n" unless $@;
            ' "${db}" || true
        done
    done
}

write_grok_conf
recover_journals

while true; do
    grok-pull -v -c "${GROK_CONF}"
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "grok-pull exited with ${rc}; retrying in ${REFRESH_SECONDS}s" >&2
    fi

    for l in ${LISTS}; do
        init_inbox "${l}"
        if git config -f "${PI_CONFIG_FILE}" --get "publicinbox.${l}.inboxdir" >/dev/null 2>&1; then
            public-inbox-index --no-fsync -j "${INDEX_JOBS}" \
                --batch-size "${INDEX_BATCH_SIZE}" "${TOPLEVEL}/${l}"
        fi
    done

    sleep "${REFRESH_SECONDS}"
done
