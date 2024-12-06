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

echo '[!] open ports are: '$openPorts

nmapScan "2-general-scan" "-sCV -p$openPorts" &
nmapScan "3-vuln-scan" "--script vuln -p$openPorts" &
nmapScan "4-aggressive-scan" "-A -p$openPorts" &

if [[ ','$openPorts',' =~ ',21,' ]]; then
    nmapPortScriptScan '21' 'ftp' &
fi
if [[ ','$openPorts',' =~ ',22,' ]]; then
    nmapPortScriptScan '22' 'ssh' &
fi
if [[ ','$openPorts',' =~ ',80,' ]]; then
    nmapPortScriptScan '80' 'http' &
fi

nmapRemainingFullPortScan $openPorts 

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
