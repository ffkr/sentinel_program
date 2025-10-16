#!/usr/bin/env bash
# Minimal, read-only security audit for Kali/Ubuntu/Debian.
# Safe to run on your own machine. No exploitation; inspection only.

set -euo pipefail

header() { printf "\n=== %s ===\n" "$1"; }
has() { command -v "$1" >/dev/null 2>&1; }

header "SYSTEM INFO"
lsb_release -a 2>/dev/null || cat /etc/os-release
uname -a

header "UPGRADABLE PACKAGES"
if has apt; then
  echo "(Refreshing package index... this does NOT change installed packages)"
  sudo apt update -y >/dev/null 2>&1 || true
  apt list --upgradable 2>/dev/null | sed -n '1,200p' || true
else
  echo "apt not found."
fi

header "FIREWALL"
if has ufw; then
  ufw status verbose || true
else
  echo "ufw not installed. Consider: sudo apt install ufw"
fi

header "LISTENING SERVICES"
(ss -lntup 2>/dev/null || netstat -lntup 2>/dev/null) | sed -n '1,80p' || echo "ss/netstat unavailable."

header "SSH CONFIG SNAPSHOT"
if [ -f /etc/ssh/sshd_config ]; then
  echo "Key directives:"
  grep -E '^(#\s*)?(Port|PermitRootLogin|PasswordAuthentication)\b' /etc/ssh/sshd_config | sed 's/^/  /' || true
else
  echo "OpenSSH server not installed or /etc/ssh/sshd_config missing."
fi

header "ACCOUNTS WITH EMPTY PASSWORD FIELD (SHOULD BE NONE)"
if [ -r /etc/shadow ]; then
  awk -F: 'length($2)==0 {print "  - " $1}' /etc/shadow || true
else
  echo "Need sudo to read /etc/shadow (e.g., sudo bash sentinel-audit.sh)."
fi

header "COMMON SUID BINARIES (REVIEW)"
for d in /bin /usr/bin /usr/local/bin /sbin /usr/sbin; do
  find "$d" -xdev -perm -4000 -type f 2>/dev/null
done | sort -u | sed 's/^/  /' | sed -n '1,200p'

header "FAIL2BAN"
if has fail2ban-client; then
  fail2ban-client status 2>/dev/null || true
else
  echo "fail2ban not installed. Consider: sudo apt install fail2ban"
fi

header "LYNIS (SECURITY AUDIT)"
if has lynis; then
  lynis audit system --quick --no-colors | sed -n '1,120p'
else
  echo "lynis not installed. Install with: sudo apt install lynis"
fi

header "RECOMMENDATIONS"
cat <<'EOF'
- Disable SSH root login (PermitRootLogin no). Use SSH keys.
- Enable a firewall (ufw) and allow only required ports.
- Apply security updates regularly.
- Use strong, unique passwords; enable MFA where possible.
- Practice only on systems you own or have explicit permission to test.
EOF
