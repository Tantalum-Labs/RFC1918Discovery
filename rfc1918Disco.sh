#!/bin/bash

SUBNET_OUTPUT="target-subnets.txt"

echo "[*] Scanning 192.168.0.0/16 in /24 chunks..."
masscan 192.168.0.0/16 \
  -p22,23,53,80,83,111,135,139,161,389,443,445,515,631,8080,8443,3389,3306,1433,5900,5901,5902,5903,1723,502,102,2000,2375,2379,27017,9200,4444,15672 \
  --rate 10000 -oG masscan-192-rfc1918.txt
python3 getSubnetsFromMasscanResults.py masscan-192-rfc1918.txt
python3 getIpsFromMasscanResults.py masscan-192-rfc1918.txt

echo "[*] Scanning 172.16.0.0/12 in /24 chunks..."
masscan 172.16.0.0/12 \
  -p22,23,53,80,83,111,135,139,161,389,443,445,515,631,8080,8443,3389,3306,1433,5900,5901,5902,5903,1723,502,102,2000,2375,2379,27017,9200,4444,15672 \
  --rate 10000 -oG masscan-172-rfc1918.txt
python3 getSubnetsFromMasscanResults.py masscan-172-rfc1918.txt
python3 getIpsFromMasscanResults.py masscan-172-rfc1918.txt

echo "[*] Scanning 10.0.0.0/8 in /24 chunks..."
masscan 10.0.0.0/8 \
  -p22,23,53,80,83,111,135,139,161,389,443,445,515,631,8080,8443,3389,3306,1433,5900,5901,5902,5903,1723,502,102,2000,2375,2379,27017,9200,4444,15672 \
  --rate 10000 -oG masscan-10-rfc1918.txt
python3 getSubnetsFromMasscanResults.py masscan-10-rfc1918.txt
python3 getIpsFromMasscanResults.py masscan-10-rfc1918.txt

echo "[*] Getting networks from routing table.."
for SUBNET in $(ip route | \
    grep -vE 'docker|br-|172\.17\.|172\.18\.|172\.19\.|169\.254\.|linkdown' | \
    grep -oE '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+)' | sort -u); do
    echo -e "${SUBNET}" > /tmp/target-subnets.txt
done

cat masscan-172-rfc1918-subnets.txt | sort -u >> /tmp/target-subnets.txt
cat masscan-192-rfc1918-subnets.txt | sort -u >> /tmp/target-subnets.txt
cat masscan-10-rfc1918-subnets.txt | sort -u >> /tmp/target-subnets.txt
cat /tmp/target-subnets.txt | sort -u > ${SUBNET_OUTPUT}
