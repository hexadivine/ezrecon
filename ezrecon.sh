#!/bin/bash
source ./ezrecon.functions.sh
##################[Set a trap to handle script termination]##################
trap 'echo "Terminating..."; exit 1' SIGINT SIGTERM

ip=$1
initScript $ip
# Nmap scan -----------------------------------------------------------------
echo '[*] Enumerating open ports'

nmapScan "1-common-ports-scan" "-v" 
openPorts=$(getOpenPortList "1-common-ports-scan")

nmapScan "2-general-scan" "-sCSV -p$openPorts" &
nmapScan "3-vul-scan" "--script vuln -p$openPorts" &
nmapScan "4-aggressive-scan" "-A -p$openPorts" &
nmapScan "5-version-scan" "-sV -p$openPorts" &

nmapRemainingFullPortScan $openPorts &

# FFUF scan -----------------------------------------------------------------

if [[ ','$openPorts',' =~ ',80,' ]]; then
    echo '[*] Enumerating dirs,files,dns on the webserver '
    ffufScan "common-scan" "/usr/share/wordlists/dirb/common.txt" &
    ffufScan "small-scan" "/usr/share/wordlists/dirb/small.txt" &
    ffufScan "big-scan" "/usr/share/wordlists/dirb/big.txt" &
    ffufScan "directory-list-1.0-scan" "/usr/share/wordlists/dirbuster/directory-list-1.0.txt" &
    ffufScan "directory-list-2.3-medium-scan" "/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt" &
    ffufScan "directory-list-2.3-small-scan" "/usr/share/wordlists/dirbuster/directory-list-2.3-small.txt" &
    ffufScan "directory-list-2.3-small-scan" "/usr/share/wordlists/dirbuster/directory-list-2.3-small.txt" &
fi

wait
echo 'Exiting Ezrecon.'
###################################################################################
