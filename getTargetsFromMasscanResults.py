#!/usr/bin/env python3
import re
import argparse
from datetime import datetime

# Known HTTP-related service identifiers
HTTP_SERVICES = {
    "http", "http-alt", "https", "https-alt", "ssl/http", "ssl/https"
}

parser = argparse.ArgumentParser(description="Extract ip:port and schema://ip:port targets from Masscan results")
parser.add_argument("inputFile", help="Path to the Masscan results file")
args = parser.parse_args()

inputFile = args.inputFile
inputFileName = inputFile.split(".")[0]
outputFile = f"{inputFileName}-targets.txt"

targets = set()

with open(inputFile, "r") as f:
    for line in f:
        match = re.search(r'Host:\s+(\d+\.\d+\.\d+\.\d+)\s+\(\)\s+Ports:\s+(\d+)/open/tcp//([^/]*)//', line)
        if match:
            ip = match.group(1)
            port = match.group(2)
            service = match.group(3).lower()

            if "https" in service:
                targets.add(f"https://{ip}:{port}")
            elif "http" in service:
                targets.add(f"http://{ip}:{port}")
            else:
                targets.add(f"{ip}:{port}")

with open(outputFile, "w") as out:
    for entry in sorted(targets):
        out.write(entry + "\n")

print(f"[+] Targets written to {outputFile}")
