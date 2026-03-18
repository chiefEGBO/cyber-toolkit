# Cyber Toolkit 

A collection of Bash scripts for basic cybersecurity tasks including network scanning, firewall reconnaissance, and automated tool installation.

---

## Features

* Subnet scanning (host discovery)
* Firewall and port filtering analysis
* Automated tool installation and execution
* Lightweight and fast

---

## Tools Included

### 1. ipsweep.sh — Subnet Scanner

Scans a subnet for active hosts using ICMP.

Usage:
./ipsweep.sh 10.0.2

---

### 2. firewall_recon.sh — Firewall Recon Tool

Performs multi-step network reconnaissance including:

* ICMP testing
* Traceroute analysis
* TCP SYN scanning
* ACK-based firewall detection
* Optional raw packet probing

Usage:
sudo ./firewall_recon.sh 192.168.1.1 --ports "22,80,443"

---

### 3. dependency-check.sh — Tool Installer

Checks if a tool is installed and installs it automatically if missing.

Usage:
./dependency-check.sh htop

---

## Requirements

* Linux (Tested on Kali)
* bash
* nmap
* traceroute
* hping3 (optional)

Install dependencies:
sudo apt install nmap traceroute hping3

---

## Learning Goals

This project demonstrates:

* Bash scripting
* Networking fundamentals
* Reconnaissance techniques
* Automation and tool management

---

## Disclaimer

This project is for educational purposes only.
Do not use these tools on networks or systems you do not own or have explicit permission to test.

---

## Author
EGBO NNAEMEKA CYPRIAN
