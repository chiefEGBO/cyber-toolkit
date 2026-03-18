#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <subnet>"
  echo "Example: $0 10.0.2"
  exit 1
fi

echo "Scanning subnet $1.0/24..."

for ip in $(seq 1 254); do
  (
    ping -c 1 -W 1 "$1.$ip" 2>/dev/null | \
    grep "64 bytes" | \
    cut -d " " -f 4 | \
    tr -d ":" &
  )
done

wait
echo "Scan complete."
