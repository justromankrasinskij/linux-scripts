#!/bin/bash

IP="$1"

if [ -z "$IP" ] && [ -z "$RUNNING_ON_REMOTE" ]; then
    echo "Server IP is required. Example: $0 1.2.3.4"
    exit 1
fi

if [ -z "$RUNNING_ON_REMOTE" ]; then
    echo "[Local] Copying SSH key to $IP..."
    ssh-copy-id root@$IP

    echo "[Local] Sending script to remote server $IP..."
    cat "$0" | ssh -t root@$IP "RUNNING_ON_REMOTE=true bash -s -- $IP"
    exit $?
fi

echo "[Remote] Configuring VPS with IP: $1"

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

set_ssh_param() {
    local param=$1
    local value=$2
    sed -i -E "/^[#[:space:]]*${param}[[:space:]]+/d" /etc/ssh/sshd_config
    echo "${param} ${value}" >> /etc/ssh/sshd_config
}

echo "" >> /etc/ssh/sshd_config

set_ssh_param "PasswordAuthentication" "no"
set_ssh_param "ChallengeResponseAuthentication" "no"
set_ssh_param "KbdInteractiveAuthentication" "no"
set_ssh_param "PubkeyAuthentication" "yes"
set_ssh_param "PermitRootLogin" "prohibit-password"

tee /etc/sysctl.d/99-disable-ipv6.conf >/dev/null <<'EOF'
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF

sysctl --system

if sshd -t; then
    echo "[Remote] SSH config is valid. Restarting SSH..."
    systemctl restart ssh || systemctl restart sshd
else
    echo "[Remote] SSH config is INVALID! Rolling back..."
    cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
    exit 1
fi
