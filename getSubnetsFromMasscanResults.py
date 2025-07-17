#!/usr/bin/env python3
import re
import ipaddress
import argparse
from datetime import datetime

parser = argparse.ArgumentParser(description="Extract subnets from Masscan results")
parser.add_argument("inputFile", help="Path to the Masscan results file")
args = parser.parse_args()

inputFile = args.inputFile
inputFileName = inputFile.split(".")[0]
outputFile = f"{inputFileName}-subnets.txt"

subnets = set()

with open(inputFile, "r") as f:
    for line in f:
        match = re.search(r'Host:\s+(\d+\.\d+\.\d+\.\d+)', line)
        if match:
            ip = match.group(1)
            try:
                subnet = ipaddress.IPv4Interface(f"{ip}/24").network
                subnets.add(str(subnet))
            except ValueError:
                continue

with open(outputFile, "w") as out:
    for subnet in sorted(subnets, key=lambda x: ipaddress.IPv4Network(x)):
        out.write(subnet + "\n")

print(f"[+] Subnets written to {outputFile}")
