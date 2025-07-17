#!/usr/bin/env python3
import re
import ipaddress
import argparse
from datetime import datetime

parser = argparse.ArgumentParser(description="Extract ips from Masscan results")
parser.add_argument("inputFile", help="Path to the Masscan results file")
args = parser.parse_args()

inputFile = args.inputFile
inputFileName = inputFile.split(".")[0]
outputFile = f"{inputFileName}-ips.txt"

ips = set()

with open(inputFile, "r") as f:
    for line in f:
        match = re.search(r'Host:\s+(\d+\.\d+\.\d+\.\d+)', line)
        if match:
            ip = match.group(1)
            try:
                ip = ipaddress.IPv4Address(f"{ip}")
                ips.add(str(ip))
            except ValueError:
                continue

with open(outputFile, "w") as out:
    for ip in sorted(ips, key=lambda x: str(x)):
        out.write(ip + "\n")

print(f"[+] Subnets written to {outputFile}")
