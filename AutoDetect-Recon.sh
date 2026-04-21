#!/bin/bash

# Colori per il terminale
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}==============================================${NC}"
echo -e "${CYAN}       AUTO DETECT V5 - STEALTH TERMINAL     ${NC}"
echo -e "${CYAN}==============================================${NC}"

# --- Controllo e Installazione JQ ---
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}[!] jq non trovato. Provo ad installarlo...${NC}"
    sudo apt install jq -y
fi

# --- Setup Cartella Report ---
mkdir -p ./reports

# --- Validazione Target ---
while true; do
    echo -ne "${YELLOW}Inserire target (es. sito.com): ${NC}"
    read T
    if [ -z "$T" ]; then continue; fi
    
    DATE=$(date +%Y%m%d_%H%M%S)
    LOGFILE="./reports/report_${T}_${DATE}.txt"
    
    echo -e "[*] Test connettività..."
    if ping -c 1 -W 1 "$T" > /dev/null 2>&1; then
        echo -e "[+] Host Online.\n"
        break
    else
        echo -e "${RED}[!] Host Offline. Procedere comunque? (s/n)${NC}"
        read ANS
        if [ "$ANS" == "s" ]; then break; fi
    fi
done

# Funzione per pulire l'output dai colori prima di salvarlo nel file
log_clean() {
    echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g' >> "$LOGFILE"
}

echo "REPORT DI ENUMERAZIONE PER: $T" > "$LOGFILE"
echo "DATA: $(date)" >> "$LOGFILE"
echo "------------------------------------" >> "$LOGFILE"

# --- 1. SOTTODOMINI ---
echo -e "${CYAN}[1] Ricerca Sottodomini...${NC}"
SUBDATA=$(curl -s "https://crt.sh/?q=%25.$T&output=json" | jq -r '.[].name_value' 2>/dev/null | sed 's/\*\.//g' | sort -u | head -n 15)
if [ ! -z "$SUBDATA" ]; then
    log_clean "\n[1] SOTTODOMINI:\n$SUBDATA"
    echo -e "${GREEN}[+] Sottodomini trovati e salvati nel report.${NC}"
else
    echo -e "${RED}[!] Nessun sottodominio trovato.${NC}"
fi

# --- 2. TECH STACK (WhatWeb) ---
echo -e "\n${CYAN}[2] Identificazione Tecnologie Web...${NC}"
if command -v whatweb &> /dev/null; then
    WWEB=$(whatweb "$T" --color=never)
    log_clean "\n[2] TECNOLOGIE:\n$WWEB"
    echo -e "${GREEN}[+] Informazioni tecnologie salvate nel report.${NC}"
else
    echo "[!] WhatWeb non trovato."
fi

# --- 3. NMAP ---
echo -e "\n${CYAN}[3] Scansione Porte & Vulnerabilità (Nmap)...${NC}"
echo -n "Avviare Nmap? (s/n): "
read RUN_NMAP
if [ "$RUN_NMAP" == "s" ]; then
    echo "[*] Scansione in corso... Attendi..."
    sudo nmap -sS -sV -Pn --top-ports 100 -T4 --script=auth,vuln "$T" > ./nmap_temp.txt
    log_clean "\n[3] RISULTATI NMAP:\n$(cat ./nmap_temp.txt)"
    rm ./nmap_temp.txt
    echo -e "${GREEN}[+] Risultati Nmap salvati con successo.${NC}"
fi

# --- 4. NIKTO ---
echo -e "\n${CYAN}[4] Analisi Vulnerabilità Web (Nikto)...${NC}"
echo -n "Avviare Nikto? (s/n): "
read RUN_NIKTO
if [ "$RUN_NIKTO" == "s" ]; then
    echo "[*] Avvio Nikto... Attendi..."
    nikto -h "$T" -Tuning 1 2 3 -Display 1 > ./nikto_temp.txt
    log_clean "\n[4] RISULTATI NIKTO:\n$(cat ./nikto_temp.txt)"
    rm ./nikto_temp.txt
    echo -e "${GREEN}[+] Risultati Nikto salvati con successo.${NC}"
fi

# --- 5. GOBUSTER ---
echo -e "\n${CYAN}[5] Directory Fuzzing (Gobuster)...${NC}"
echo -n "Avviare Gobuster? (s/n): "
read RUN_GOB
if [ "$RUN_GOB" == "s" ]; then
    WLIST="/usr/share/wordlists/dirb/common.txt"
    if [ -f "$WLIST" ]; then
        echo "[*] Gobuster in esecuzione... Attendi..."
        gobuster dir -u "http://$T" -w "$WLIST" -t 20 -q > ./gob_temp.txt
        log_clean "\n[5] DIRECTORY TROVATE:\n$(cat ./gob_temp.txt)"
        rm ./gob_temp.txt
        echo -e "${GREEN}[+] Risultati Gobuster salvati con successo.${NC}"
    else
        echo -e "${RED}[!] Wordlist non trovata.${NC}"
    fi
fi

echo -e "\n${YELLOW}==============================================${NC}"
echo -e "${YELLOW}  OPERAZIONE FINITA!                          ${NC}"
echo -e "${YELLOW}  Controlla il file: $LOGFILE                ${NC}"
echo -e "${YELLOW}==============================================${NC}"
