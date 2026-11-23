#!/usr/bin/env bash
# Lab: a simple firewall with ufw (deny incoming by default, allow SSH and HTTP).
run() { echo "\$ $*"; "$@"; echo; }

run sudo ufw --force reset
run sudo ufw default deny incoming
run sudo ufw default allow outgoing
run sudo ufw allow 22/tcp comment SSH
run sudo ufw allow 80/tcp comment HTTP
run sudo ufw --force enable
run sudo ufw status verbose
run sudo ufw status numbered
echo "--- ssh over loopback still works:"
run ssh -i ~/.ssh/lab_ed25519 -o IdentitiesOnly=yes deployer@localhost whoami
