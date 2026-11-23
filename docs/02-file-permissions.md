# 2. File permissions

## Goal

Understand how `rwx` permissions work for the owner, the group and everyone else, and show that giving a *group* access is safer than opening a file to everyone.

## Reading `ls -l`

```text
-rw-r-----  muneeb  devops  secret.txt
```

- First character: file type (`-` file, `d` directory)
- Next 9 characters: owner `rw-`, group `r--`, others `---`
- Numbers: r = 4, w = 2, x = 1, so `rw-` = 6, `r--` = 4, `---` = 0. `640` means `rw-r-----`.

## Lab

The script `scripts/permissions-lab.sh` creates a file, changes its mode and group, and tries to read it as the `deployer` user from topic 1.

1. Mode `600` (owner only): `deployer` gets `Permission denied`.
2. Group changed to `devops` and mode `640`: `deployer` is in `devops`, so it can read the file.

## Notes

- `chmod 600` for secrets (keys, tokens), `640` when a group must read, `755` for scripts and directories.
- Never use `chmod 777`. Use a group instead.
- A directory needs the `x` bit so a user can enter it.
- `chgrp devops FILE` changes the group, `chown USER:GROUP FILE` changes both.

## Output (real run)

```text
$ ls -l secret.txt
-rw-r--r-- 1 muneeb muneeb 7 Nov 23 17:23 secret.txt

$ chmod 600 secret.txt

$ ls -l secret.txt
-rw------- 1 muneeb muneeb 7 Nov 23 17:23 secret.txt

--- deployer tries to read a file with mode 600 (owner only):
$ sudo -u deployer cat /tmp/permissions-lab/secret.txt
cat: /tmp/permissions-lab/secret.txt: Permission denied

$ sudo chgrp devops secret.txt

$ chmod 640 secret.txt

$ ls -l secret.txt
-rw-r----- 1 muneeb devops 7 Nov 23 17:23 secret.txt

--- deployer is in group devops, so now it can read the file:
$ sudo -u deployer cat /tmp/permissions-lab/secret.txt
secret

```
