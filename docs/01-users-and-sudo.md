# 1. Users, groups and sudo

## Goal

Create a normal user, `deployer`, that will run the app later. It has no admin rights, so a compromised app cannot take over the whole server (least privilege).

## Commands

```bash
sudo adduser --disabled-password --gecos "" deployer
sudo groupadd devops
sudo usermod -aG devops deployer
```

## Notes

- `--disabled-password`: the user cannot log in with a password. I will use an SSH key later.
- `usermod -aG`: the `-a` (append) is important. Without it, the user loses all their other groups.
- A normal user cannot run `sudo`. Only members of the `sudo` group can.
- Useful checks: `id USER` shows the uid and groups, `getent passwd USER` shows the account entry.

## Output

```text
$ id deployer
uid=1001(deployer) gid=1001(deployer) groups=1001(deployer),100(users),1002(devops)
$ sudo -l -U deployer
User deployer is not allowed to run sudo on DESKTOP-STHMOKV.
$ sudo -u deployer whoami
deployer
```
