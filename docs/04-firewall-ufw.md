# 4. Firewall with ufw

## Goal

Block everything coming in by default and open only what the server needs: SSH (22) and HTTP (80).

## Concepts

- Default policy: deny incoming, allow outgoing.
- Rules are checked in order. `ufw status numbered` shows the order, and `ufw delete N` removes rule number N.
- Allow SSH before enabling the firewall. On a remote server, the wrong order locks you out.
- `ufw limit 22/tcp` adds rate limiting (it blocks an IP that opens many connections quickly). It is a good choice for SSH on a public server.
- ufw is a friendly front end for iptables/nftables.
- Every rule appears twice: once for IPv4 and once for IPv6 `(v6)`.

## Lab

`scripts/ufw-lab.sh` resets ufw, sets the defaults, opens ports 22 and 80, enables the firewall, and checks that SSH over `localhost` still works.

## Notes

- Traffic on the loopback interface is always allowed by ufw's default rules, so the `localhost` test shows that SSH is not broken, but it does not prove that other ports are blocked. A test from another machine would.
- `ufw --force reset` removes all rules. Use it only in a lab.

## Output (real run)

```text
$ sudo ufw --force reset
Backing up 'user.rules' to '/etc/ufw/user.rules.20261123_173620'
Backing up 'before.rules' to '/etc/ufw/before.rules.20261123_173620'
Backing up 'after.rules' to '/etc/ufw/after.rules.20261123_173620'
Backing up 'user6.rules' to '/etc/ufw/user6.rules.20261123_173620'
Backing up 'before6.rules' to '/etc/ufw/before6.rules.20261123_173620'
Backing up 'after6.rules' to '/etc/ufw/after6.rules.20261123_173620'


$ sudo ufw default deny incoming
Default incoming policy changed to 'deny'
(be sure to update your rules accordingly)

$ sudo ufw default allow outgoing
Default outgoing policy changed to 'allow'
(be sure to update your rules accordingly)

$ sudo ufw allow 22/tcp comment SSH
Rules updated
Rules updated (v6)

$ sudo ufw allow 80/tcp comment HTTP
Rules updated
Rules updated (v6)

$ sudo ufw --force enable
Firewall is active and enabled on system startup

$ sudo ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere                   # SSH
80/tcp                     ALLOW IN    Anywhere                   # HTTP
22/tcp (v6)                ALLOW IN    Anywhere (v6)              # SSH
80/tcp (v6)                ALLOW IN    Anywhere (v6)              # HTTP


$ sudo ufw status numbered
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 22/tcp                     ALLOW IN    Anywhere                   # SSH
[ 2] 80/tcp                     ALLOW IN    Anywhere                   # HTTP
[ 3] 22/tcp (v6)                ALLOW IN    Anywhere (v6)              # SSH
[ 4] 80/tcp (v6)                ALLOW IN    Anywhere (v6)              # HTTP


--- ssh over loopback still works:
$ ssh -i /home/muneeb/.ssh/lab_ed25519 -o IdentitiesOnly=yes deployer@localhost whoami
deployer

```
