#!/usr/bin/with-contenv bash

log() {
    local message="$1"
    local timestamp=$(date +"%Y.%m.%dT%H:%M:%S")
    echo "${timestamp} (qbt-slowban) (cleaner) ${message}"
}

if [[ -n "${SLOWBAN_BANNED_PEERS}" ]]; then
    banned_ips=$(echo "${SLOWBAN_BANNED_PEERS}" | tr ',' '\n')
else
    banned_ips=""
fi

response=$(curl --silent --request POST --url "http://localhost:${WEBUI_PORT}/api/v2/app/setPreferences" --data-urlencode "json={\"banned_IPs\": \"${banned_ips}\"}")

if [[ $? -eq 0 ]]; then
    log "banlist updated successfully"
else
    log "error updating banlist"
fi
