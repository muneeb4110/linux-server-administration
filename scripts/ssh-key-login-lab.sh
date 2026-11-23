#!/usr/bin/env bash
# Lab: key-based SSH login to the "deployer" user on this machine.
KEY=~/.ssh/lab_ed25519
run() { echo "\$ $*"; "$@"; echo; }

mkdir -p ~/.ssh && chmod 700 ~/.ssh
rm -f "$KEY" "$KEY.pub"
run ssh-keygen -q -t ed25519 -N "" -C "wsl-lab" -f "$KEY"
run ls -l "$KEY" "$KEY.pub"

sudo rm -rf /home/deployer/.ssh
run sudo install -d -m 700 -o deployer -g deployer /home/deployer/.ssh
run sudo install -m 600 -o deployer -g deployer "$KEY.pub" /home/deployer/.ssh/authorized_keys
run sudo ls -ld /home/deployer/.ssh
run sudo ls -l /home/deployer/.ssh/authorized_keys

echo "--- log in as deployer with the key (no password):"
run ssh -i "$KEY" -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new deployer@localhost "whoami; hostname"
