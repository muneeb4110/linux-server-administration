#!/usr/bin/env bash
# Lab: harden sshd (no passwords, limited tries) and prove it works.
KEY=~/.ssh/lab_ed25519
run() { echo "\$ $*"; "$@"; echo; }

sudo tee /etc/ssh/sshd_config.d/00-hardening.conf >/dev/null <<'CONF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
MaxAuthTries 3
CONF
echo '$ cat /etc/ssh/sshd_config.d/00-hardening.conf'
cat /etc/ssh/sshd_config.d/00-hardening.conf
echo

run sudo sshd -t
run sudo systemctl restart ssh
echo '$ sudo sshd -T | grep -Ei "passwordauthentication|permitrootlogin|maxauthtries"'
sudo sshd -T | grep -Ei "passwordauthentication|permitrootlogin|maxauthtries"
echo

echo "--- the key still works:"
run ssh -i "$KEY" -o IdentitiesOnly=yes deployer@localhost whoami
echo "--- password login is refused (we do not offer the key):"
run ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password -o BatchMode=yes deployer@localhost whoami
