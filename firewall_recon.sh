#!/usr/bin/env bash

# firewall_recon.sh
# Usage: sudo ./firewall_recon.sh <TARGET_IP> [--ports "22,80,443"] [--fast]
# Requires: nmap, traceroute (or traceroute6), hping3 (optional)

set -euo pipefail

TARGET="${1:-}"
PORTS="22,80,443"
FAST=false

# parse optional args
shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ports) PORTS="$2"; shift 2;;
    --fast) FAST=true; shift;;
    *) echo "Unknown arg: $1"; exit 1;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "Usage: sudo $0 <TARGET_IP> [--ports \"22,80,443\"] [--fast]"
  exit 1
fi

echo "== Recon summary for: $TARGET =="
echo "Timestamp: $(date -u +"%Y-%m-%d %H:%M:%SZ")"
echo

# 1) Basic ping / ICMP test (may be blocked)
echo "[1/5] ICMP test (ping)"
if ping -c 3 -W 1 "$TARGET" &>/dev/null; then
  echo " -> ICMP Echo Reply: OK (host replies to ping)"
else
  echo " -> No ICMP reply (ICMP may be blocked or host down)"
fi
echo

# 2) Traceroute (ICMP) to see path
echo "[2/5] Traceroute (ICMP)"
if command -v traceroute &>/dev/null; then
  traceroute -I -m 20 "$TARGET" | sed -n '1,12p'
else
  echo " traceroute not installed"
fi
echo

# 3) Quick top-ports TCP SYN scan (fast or full)
echo "[3/5] TCP SYN scan (top ports)"
if $FAST; then
  nmap -sS -Pn -p- --min-rate 5000 --top-ports 100 -oG - "$TARGET" | sed -n '1,200p'
else
  nmap -sS -Pn -p- --min-rate 1000 -T4 --reason --open -oG - "$TARGET" | sed -n '1,400p'
fi
echo

# 4) ACK scan to test statefulness for chosen ports
echo "[4/5] ACK scan on ports: $PORTS"
nmap -sA -Pn -p "$PORTS" --reason "$TARGET" -oG - | sed -n '1,120p'
echo

# 5) Optional: hping3 probe (SYN) to see raw replies (if installed)
if command -v hping3 &>/dev/null; then
  echo "[5/5] hping3 SYN probe (SYN packets to $TARGET:$PORTS)"
  IFS=',' read -ra PP <<< "$PORTS"
  for p in "${PP[@]}"; do
    echo " -> port $p"
    sudo timeout 4 hping3 -S -p "$p" -c 3 "$TARGET" 2>/dev/null | sed -n '1,50p' || true
  done
else
  echo "[5/5] hping3 not installed — install hping3 for raw TCP tests (optional)"
fi

# Simple heuristic summary:
echo
echo "=== Heuristic Summary ==="
# detect if any open ports found (quick parse)
OPEN_COUNT=$(nmap -sS -Pn -p "$PORTS" --open "$TARGET" -oG - 2>/dev/null | grep -c "Ports:")
if grep -q "Host is up" <<< "$(nmap -Pn -p "$PORTS" "$TARGET" -oG - 2>/dev/null)"; then
  echo "Host appears up (responded to probes or TCP)."
fi

# Check for many filtered ports on full scan (slow) only when not fast
if ! $FAST; then
  FILTERED=$(nmap -sS -Pn -p- --reason "$TARGET" -oG - | grep -c "filtered")
  if [[ $FILTERED -gt 50 ]]; then
    echo "Many ports appear FILTERED — a firewall or ACL likely dropping probes."
  fi
fi

echo "If results are ambiguous, try running with --fast or add more targeted probes."
echo "End of scan. Interpret results carefully — false positives possible (host down, rate-limiting, IDS)."
