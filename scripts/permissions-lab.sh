#!/usr/bin/env bash
# Small lab: how file permissions and groups control access.
LAB=/tmp/permissions-lab
rm -rf "$LAB"
mkdir "$LAB"
cd "$LAB" || exit 1

run() { echo "\$ $*"; "$@"; echo; }

echo "secret" > secret.txt
run ls -l secret.txt

run chmod 600 secret.txt
run ls -l secret.txt
echo "--- deployer tries to read a file with mode 600 (owner only):"
run sudo -u deployer cat "$LAB/secret.txt"

run sudo chgrp devops secret.txt
run chmod 640 secret.txt
run ls -l secret.txt
echo "--- deployer is in group devops, so now it can read the file:"
run sudo -u deployer cat "$LAB/secret.txt"
