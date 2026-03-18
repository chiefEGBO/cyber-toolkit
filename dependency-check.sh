#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <tool-name>"
  echo "Example: $0 htop"
  exit 1
fi

tool=$1

if command -v "$tool" &>/dev/null; then
  echo "$tool is already installed. Launching..."
else
  echo "$tool is NOT installed. Installing..."
  sudo apt update && sudo apt install -y "$tool"
fi

$tool
