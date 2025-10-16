# Sentinel Audit

Minimal, **read-only** security audit script for Kali/Ubuntu/Debian.  
No exploitation—**inspection only**. Ideal for education, baselining, and hardening checklists.

---

## What it checks

- **System info**: OS release, kernel
- **Upgradable packages** (`apt`)
- **Firewall** status (`ufw`)
- **Listening services** (`ss` or `netstat`)
- **SSH config snapshot**: `Port`, `PermitRootLogin`, `PasswordAuthentication`
- **Accounts with empty password fields** (from `/etc/shadow`)
- **Common SUID binaries** (quick review list)
- **Fail2ban** status (if installed)
- **Lynis quick audit** (if installed)
- **Actionable tips** at the end

> All operations are *read-only*. Sections are skipped gracefully if a tool isn’t installed.

---

## Requirements

- Debian-based Linux (Kali/Ubuntu/Debian)
- `apt` available
- Optional tools (recommended):
  - `ufw` — firewall control
  - `fail2ban` — brute-force protection
  - `lynis` — security auditing framework
  - `iproute2` (`ss`) or `net-tools` (`netstat`)

Install optional tools:
~~~
sudo apt update
sudo apt install -y ufw fail2ban lynis
~~~

---

## Usage

Clone or download this repo, then run:

~~~
chmod +x sentinel-audit.sh
sudo ./sentinel-audit.sh
~~~

Save output to a log file:
~~~
sudo ./sentinel-audit.sh | tee "audit-$(hostname)-$(date +%F).log"
~~~

Run without `sudo`?
- You’ll still get most sections, but privileged checks (e.g., `/etc/shadow`, some service status) will be skipped.

---

## Sample output (trimmed)

~~~
=== SYSTEM INFO ===
NAME="Debian GNU/Linux"
Linux demo 6.6.0-... x86_64

=== UPGRADABLE PACKAGES ===
libssl1.1/stable 1.1.1x upgradeable from 1.1.1w
...

=== FIREWALL ===
Status: active
To                         Action      From
22/tcp                     ALLOW       Anywhere

=== SSH CONFIG SNAPSHOT ===
  Port 22
  PermitRootLogin no
  PasswordAuthentication no

=== RECOMMENDATIONS ===
- Disable SSH root login (PermitRootLogin no). Use SSH keys.
- Enable a firewall (ufw) and allow only required ports.
...
~~~

---

## File list

- `sentinel-audit.sh` — the script (read-only checks)
- `README.md` — this document

---

## Exit behavior

The script uses `set -euo pipefail` and handles missing/optional tools gracefully, so it won’t abort the whole run if a single check isn’t available.

---

## Ethos & scope (read this)

This project is for **defensive** and **educational** use on systems you **own** or are **explicitly authorized** to assess. It does **not** perform exploitation, intrusion, or service disruption. Always follow local laws and organizational policies.

---

## Contributing

Issues and PRs welcome:
- Keep checks **read-only**.
- Prefer lightweight, fast commands.
- Guard each optional dependency with availability checks.

---

-- hehe FUKURO 
