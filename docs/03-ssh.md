# 3. SSH server and key-based login

## Goal

Run an SSH server and log in without a password, using a key pair (the way real servers are accessed).

## How it works

- `ssh-keygen -t ed25519` creates a key pair. The private key stays with me, the public key goes to the server.
- The public key is added to `~/.ssh/authorized_keys` of the user I want to log in as (here: `deployer`).
- sshd refuses keys when permissions are too open, so `~/.ssh` must be `700` and `authorized_keys` must be `600` (see topic 2).
- On Ubuntu, `ssh` is started by `ssh.socket` when a connection arrives (socket activation).

## Lab

`scripts/ssh-key-login-lab.sh` creates the key pair, installs the public key for `deployer` with strict permissions, and logs in as `deployer` without a password.

## Notes

- Never share the private key (`lab_ed25519`). Only `lab_ed25519.pub` is shared.
- For a real server, protect the private key with a passphrase. I used an empty one only for this local lab.
- `StrictHostKeyChecking=accept-new` trusts a host the first time it is seen and warns if its key changes later.

## Output (real run)

```text
$ ssh-keygen -q -t ed25519 -N  -C wsl-lab -f /home/muneeb/.ssh/lab_ed25519

$ ls -l /home/muneeb/.ssh/lab_ed25519 /home/muneeb/.ssh/lab_ed25519.pub
-rw------- 1 muneeb muneeb 399 Nov 23 17:29 /home/muneeb/.ssh/lab_ed25519
-rw-r--r-- 1 muneeb muneeb  89 Nov 23 17:29 /home/muneeb/.ssh/lab_ed25519.pub

$ sudo install -d -m 700 -o deployer -g deployer /home/deployer/.ssh

$ sudo install -m 600 -o deployer -g deployer /home/muneeb/.ssh/lab_ed25519.pub /home/deployer/.ssh/authorized_keys

$ sudo ls -ld /home/deployer/.ssh
drwx------ 2 deployer deployer 4096 Nov 23 17:29 /home/deployer/.ssh

$ sudo ls -l /home/deployer/.ssh/authorized_keys
-rw------- 1 deployer deployer 89 Nov 23 17:29 /home/deployer/.ssh/authorized_keys

--- log in as deployer with the key (no password):
$ ssh -i /home/muneeb/.ssh/lab_ed25519 -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new deployer@localhost whoami; hostname
Warning: Permanently added 'localhost' (ED25519) to the list of known hosts.
deployer
DESKTOP-STHMOKV

```

## Hardening the SSH server

`scripts/ssh-hardening-lab.sh` writes `/etc/ssh/sshd_config.d/00-hardening.conf` with:

- `PasswordAuthentication no` and `KbdInteractiveAuthentication no`: only keys are accepted, so password-guessing bots get nowhere.
- `PermitRootLogin no`: nobody logs in directly as root.
- `MaxAuthTries 3`: fewer guesses per connection.

Lessons:

- sshd uses the first value it finds, and files in `sshd_config.d/` are read in alphabetical order, so the file is named `00-hardening.conf`.
- Run `sudo sshd -t` before restarting, so a typo does not lock me out.
- On a real server, keep one SSH session open while testing a new config.

## Output (hardening run)

```text
$ cat /etc/ssh/sshd_config.d/00-hardening.conf
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
MaxAuthTries 3

$ sudo sshd -t

$ sudo systemctl restart ssh

$ sudo sshd -T | grep -Ei "passwordauthentication|permitrootlogin|maxauthtries"
maxauthtries 3
permitrootlogin no
passwordauthentication no

--- the key still works:
$ ssh -i /home/muneeb/.ssh/lab_ed25519 -o IdentitiesOnly=yes deployer@localhost whoami
deployer

--- password login is refused (we do not offer the key):
$ ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password -o BatchMode=yes deployer@localhost whoami
deployer@localhost: Permission denied (publickey).

```
