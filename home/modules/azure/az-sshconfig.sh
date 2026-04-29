#!/bin/bash
set -e

CERT_FILE=~/.ssh/az_ssh_config/all_ips/id_rsa.pub-aadcert.pub
BUFFER_SECONDS=300  # 5-minute buffer before expiry

refresh_keys() {
    rm -rf ~/.ssh/az_ssh_config/*
    az ssh config --ip \* --file ~/.ssh/az-sshconfig
}

if [ ! -f "$CERT_FILE" ]; then
    echo "No certificate found, fetching..." >&2
    refresh_keys
    exit 0
fi

# Extract expiry from cert
EXPIRY=$(ssh-keygen -L -f "$CERT_FILE" 2>/dev/null | grep "Valid:" | sed 's/.*to //')
if [ -z "$EXPIRY" ]; then
    echo "Cannot read cert expiry, refetching..." >&2
    refresh_keys
    exit 0
fi

EXPIRY_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$EXPIRY" +%s 2>/dev/null)
NOW_EPOCH=$(date +%s)

if [ $(( EXPIRY_EPOCH - NOW_EPOCH )) -le $BUFFER_SECONDS ]; then
    echo "Certificate expired or expiring soon, refetching..." >&2
    refresh_keys
else
    REMAINING=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 60 ))
    echo "Certificate still valid (~${REMAINING}min remaining), skipping refresh." >&2
fi
