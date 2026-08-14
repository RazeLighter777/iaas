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
# public-inbox-index needs jobs >= shards+1 (one master + one worker per
# Xapian shard); inboxes here are created with 3 shards, hence 4.
INDEX_JOBS=${INDEX_JOBS:-4}
INDEX_LEVEL=${INDEX_LEVEL:-full}
INDEX_BATCH_SIZE=${INDEX_BATCH_SIZE:-10m}
INDEX_PARALLEL=${INDEX_PARALLEL:-1}
EXTINDEX_JOBS=${EXTINDEX_JOBS:-0}
EXTINDEX_DIR=${TOPLEVEL}/extindex
CSS_DIR=/usr/share/lore-mirror
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

# Match lore.kernel.org's web appearance: its light/dark 216-color stylesheets,
# real list descriptions (grokmirror stores lore's description in each epoch
# repo; strip the "[epoch N]" suffix), and short inbox names on the landing
# page. WwwListing renders the bare name only when publicinbox.<name>.url is
# unset (URLs then derive from the request Host header, which suits a mirror),
# but its non-extindex code path filters inboxes BY their configured urls, so
# unsetting them before [extindex "all"] exists empties the landing page: keep
# urls until the extindex is registered, drop them after.
sync_www_cosmetics() {
    if ! git config -f "${PI_CONFIG_FILE}" --get-all publicinbox.css >/dev/null 2>&1; then
        git config -f "${PI_CONFIG_FILE}" --add publicinbox.css \
            "${CSS_DIR}/216light.css media=screen,print"
        git config -f "${PI_CONFIG_FILE}" --add publicinbox.css \
            "${CSS_DIR}/216dark.css media='screen and (prefers-color-scheme:dark)'"
    fi
    with_all=0
    git config -f "${PI_CONFIG_FILE}" --get extindex.all.topdir >/dev/null 2>&1 && with_all=1
    for l in ${LISTS}; do
        [ -d "${TOPLEVEL}/${l}" ] || continue
        if [ "${with_all}" = 1 ]; then
            git config -f "${PI_CONFIG_FILE}" --unset-all "publicinbox.${l}.url" 2>/dev/null || true
        elif ! git config -f "${PI_CONFIG_FILE}" --get "publicinbox.${l}.url" >/dev/null 2>&1; then
            git config -f "${PI_CONFIG_FILE}" "publicinbox.${l}.url" "${URL_BASE}/${l}"
        fi
        desc_src="${TOPLEVEL}/${l}/git/0.git/description"
        [ -f "${desc_src}" ] || continue
        desc=$(sed 's/ \[epoch [0-9]*\]$//' "${desc_src}")
        case "${desc}" in ''|Unnamed*) continue;; esac
        [ "${desc}" = "$(cat "${TOPLEVEL}/${l}/description" 2>/dev/null)" ] && continue
        printf '%s\n' "${desc}" > "${TOPLEVEL}/${l}/description"
    done
}

# Cross-list search index ("all/", like lore.kernel.org's): also gives the
# landing page its search form. Only registered in the config (making the web
# UI use it) after the first full build completes, so the listing never runs
# off a partially-populated misc index.
run_extindex() {
    [ "${EXTINDEX_JOBS}" = 0 ] && return 0
    if public-inbox-extindex --all --no-fsync -j "${EXTINDEX_JOBS}" \
            --batch-size "${INDEX_BATCH_SIZE}" "${EXTINDEX_DIR}"; then
        host=${URL_BASE#*://}
        printf 'All of %s\n' "${host%%/*}" > "${EXTINDEX_DIR}/description"
        if ! git config -f "${PI_CONFIG_FILE}" --get extindex.all.topdir >/dev/null 2>&1; then
            git config -f "${PI_CONFIG_FILE}" extindex.all.topdir "${EXTINDEX_DIR}"
        fi
    fi
}

# An unclean shutdown mid-index leaves hot SQLite rollback journals that the
# read-only httpd workers cannot recover (they 500 instead). Recover them by
# briefly opening each database read-write before serving/indexing resumes.
recover_journals() {
    extindex_dbs=""
    [ -d "${EXTINDEX_DIR}" ] && \
        extindex_dbs=$(find "${EXTINDEX_DIR}" -name '*.sqlite3' 2>/dev/null)
    {
        for l in ${LISTS}; do
            printf '%s\n' "${TOPLEVEL}/${l}/msgmap.sqlite3" \
                          "${TOPLEVEL}/${l}/over.sqlite3" \
                          "${TOPLEVEL}/${l}/xap15/over.sqlite3"
        done
        [ -n "${extindex_dbs}" ] && printf '%s\n' "${extindex_dbs}"
    } | while read -r db; do
        [ -f "${db}-journal" ] || continue
        perl -MDBI -e '
            my $dbh = eval { DBI->connect("dbi:SQLite:dbname=$ARGV[0]", "", "",
                {RaiseError => 1, sqlite_busy_timeout => 5000}) } or exit 0;
            eval { $dbh->do("BEGIN IMMEDIATE"); $dbh->do("COMMIT") };
            print "recovered journal: $ARGV[0]\n" unless $@;
        ' "${db}" || true
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

    # Init every inbox before indexing any: indexing a large list takes days,
    # and the others' web endpoints only exist once initialized.
    for l in ${LISTS}; do
        init_inbox "${l}"
    done
    sync_www_cosmetics
    # Index inboxes, up to INDEX_PARALLEL lists at a time (separate inboxes
    # have independent databases, so concurrent indexing is safe).
    export TOPLEVEL PI_CONFIG_FILE INDEX_JOBS INDEX_BATCH_SIZE
    printf '%s\n' ${LISTS} | xargs -P "${INDEX_PARALLEL}" -I{} bash -c '
        l={}
        git config -f "${PI_CONFIG_FILE}" --get "publicinbox.${l}.inboxdir" >/dev/null 2>&1 || exit 0
        exec public-inbox-index --no-fsync -j "${INDEX_JOBS}" \
            --batch-size "${INDEX_BATCH_SIZE}" "${TOPLEVEL}/${l}"
    '
    # After the per-list indexes are current (the xargs above blocks until
    # then), fold everything into the cross-list "all" extindex.
    run_extindex

    sleep "${REFRESH_SECONDS}"
done
