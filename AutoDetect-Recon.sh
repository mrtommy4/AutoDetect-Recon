#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}==============================================${NC}"
echo -e "${CYAN}       AUTO DETECT V5 - STEALTH TERMINAL     ${NC}"
echo -e "${CYAN}==============================================${NC}"

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}[!] jq not found. Installing...${NC}"
    sudo apt update && sudo apt install jq -y
fi

mkdir -p ./reports

while true; do
    echo -ne "${YELLOW}Enter target (e.g., site.com): ${NC}"
    read T
    if [ -z "$T" ]; then continue; fi
    
    DATE=$(date +%Y%m%d_%H%M%S)
    LOGFILE="./reports/report_${T}_${DATE}.txt"
    
    echo -e "[*] Testing connectivity..."
    if ping -c 1 -W 1 "$T" > /dev/null 2>&1; then
        echo -e "[+] Host Online.\n"
        break
    else
        echo -e "${RED}[!] Host Offline. Proceed anyway? (y/n)${NC}"
        read ANS
        if [ "$ANS" == "y" ]; then break; fi
    fi
done

log_clean() {
    echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g' >> "$LOGFILE"
}

echo "ENUMERATION REPORT FOR: $T" > "$LOGFILE"
echo "DATE: $(date)" >> "$LOGFILE"
echo "------------------------------------" >> "$LOGFILE"

echo -e "${CYAN}[1] Searching Subdomains...${NC}"
SUBDATA=$(curl -s "https://crt.sh/?q=%25.$T&output=json" | jq -r '.[].name_value' 2>/dev/null | sed 's/\*\.//g' | sort -u | head -n 15)
if [ ! -z "$SUBDATA" ]; then
    log_clean "\n[1] SUBDOMAINS:\n$SUBDATA"
    echo -e "${GREEN}[+] Subdomains found and saved to report.${NC}"
else
    echo -e "${RED}[!] No subdomains found.${NC}"
fi

echo -e "\n${CYAN}[2] Identifying Web Technologies...${NC}"
if command -v whatweb &> /dev/null; then
    WWEB=$(whatweb "$T" --color=never)
    log_clean "\n[2] TECHNOLOGIES:\n$WWEB"
    echo -e "${GREEN}[+] Technology info saved to report.${NC}"
else
    echo "[!] WhatWeb not found."
fi

echo -e "\n${CYAN}[3] Port Scanning & Vuln Check (Nmap)...${NC}"
echo -n "Start Nmap? (y/n): "
read RUN_NMAP
if [ "$RUN_NMAP" == "y" ]; then
    echo "[*] Scanning in progress... Please wait..."
    sudo nmap -sS -sV -Pn --top-ports 100 -T4 --script=auth,vuln "$T" > ./nmap_temp.txt
    log_clean "\n[3] NMAP RESULTS:\n$(cat ./nmap_temp.txt)"
    rm ./nmap_temp.txt
    echo -e "${GREEN}[+] Nmap results saved successfully.${NC}"
fi

echo -e "\n${CYAN}[4] Web Vulnerability Analysis (Nikto)...${NC}"
echo -n "Start Nikto? (y/n): "
read RUN_NIKTO
if [ "$RUN_NIKTO" == "y" ]; then
    echo "[*] Launching Nikto... Please wait..."
    nikto -h "$T" -Tuning 1 2 3 -Display 1 > ./nikto_temp.txt
    log_clean "\n[4] NIKTO RESULTS:\n$(cat ./nikto_temp.txt)"
    rm ./nikto_temp.txt
    echo -e "${GREEN}[+] Nikto results saved successfully.${NC}"
fi

echo -e "\n${CYAN}[5] Directory Fuzzing (Gobuster)...${NC}"
echo -n "Start Gobuster? (y/n): "
read RUN_GOB
if [ "$RUN_GOB" == "y" ]; then
    WLIST="/usr/share/wordlists/dirb/common.txt"
    if [ -f "$WLIST" ]; then
        echo "[*] Gobuster running... Please wait..."
        gobuster dir -u "http://$T" -w "$WLIST" -t 20 -q > ./gob_temp.txt
        log_clean "\n[5] DIRECTORIES FOUND:\n$(cat ./gob_temp.txt)"
        rm ./gob_temp.txt
        echo -e "${GREEN}[+] Gobuster results saved successfully.${NC}"
    else
        echo -e "${RED}[!] Wordlist not found.${NC}"
    fi
fi

echo -e "\n${YELLOW}==============================================${NC}"
echo -e "${YELLOW}  SCAN FINISHED!                              ${NC}"
echo -e "${YELLOW}  Check the file: $LOGFILE                   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
