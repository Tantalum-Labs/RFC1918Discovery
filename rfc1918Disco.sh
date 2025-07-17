#!/bin/bash

SUBNET_OUTPUT="target-subnets.txt"
IP_OUTPUT="discovered-ips.txt"
TARGETS_OUTPUT="discovered-targets.txt"

EXTENSIVE_PORTS="22,23,53,80,83,102,111,135,139,161,389,443,445,502,515,631,1433,1723,2000,2375,2379,3306,3389,4444,5900,5901,5902,5903,8080,8443,9200,15672,27017"
QUICK_PORTS="22,80,443,445,3389"

if [[ "$EUID" -ne 0 ]]; then
    echo "[-] Error: This script must be run as root. Please run with sudo or as root user."
    exit 1
fi

if ! command -v masscan >/dev/null 2>&1; then
    echo "[-] Error: masscan is not installed. Please install masscan to continue."
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "[-] Error: python3 is not installed. Please install python3 to continue."
    exit 1
fi

if [[ "$1" == "--quick" ]]; then
    PORTS="${QUICK_PORTS}"
    echo "[*] Using quick port set: ${PORTS}"
else
    PORTS="${EXTENSIVE_PORTS}"
    echo "[*] Using extensive port set: ${PORTS}"
fi

function run_masscan() {
    local cidr=$1
    local filename=$2

    if [[ -f "${filename}" ]]; then
        read -p "[?] ${filename} already exists. Skip scan? [Y/n] " choice
        case "$choice" in
            [nN]*) ;;
            *) echo "[*] Skipping scan of ${cidr}"; return ;;
        esac
    fi

    echo "[*] Scanning ${cidr} in /24 chunks..."
    masscan "${cidr}" -p "${PORTS}" --rate 10000 -oG "${filename}"
}

function process_results() {
    local filename=$1
    python3 getSubnetsFromMasscanResults.py "${filename}"
    python3 getIpsFromMasscanResults.py "${filename}"
    python3 getTargetsFromMasscanResults.py "${filename}"
}

run_masscan "192.168.0.0/16" "masscan-192-rfc1918.txt"
process_results "masscan-192-rfc1918.txt"

run_masscan "172.16.0.0/12" "masscan-172-rfc1918.txt"
process_results "masscan-172-rfc1918.txt"

run_masscan "10.0.0.0/8" "masscan-10-rfc1918.txt"
process_results "masscan-10-rfc1918.txt"

echo "[*] Getting networks from routing table..."
for SUBNET in $(ip route | \
    grep -vE 'docker|br-|172\.17\.|172\.18\.|172\.19\.|169\.254\.|linkdown' | \
    grep -oE '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+)' | sort -u); do
    echo "${SUBNET}" >> /tmp/target-subnets.txt
done

cat masscan-*-rfc1918-subnets.txt >> /tmp/target-subnets.txt
sort -u /tmp/target-subnets.txt > "${SUBNET_OUTPUT}"

cat masscan-*-rfc1918-ips.txt >> /tmp/discovered-ips.txt
sort -u /tmp/discovered-ips.txt > "${IP_OUTPUT}"

cat masscan-*-rfc1918-targets.txt >> /tmp/discovered-targets.txt
sort -u /tmp/discovered-targets.txt > "${TARGETS_OUTPUT}"
