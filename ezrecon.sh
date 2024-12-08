#!/bin/bash
source ./ezrecon.functions.sh

# Initial setup -----------------------------------------------------------------

cleanup() {
    kill 0 
}
trap cleanup EXIT SIGINT SIGTERM
ip=$1
initScript $ipnmapScan "3-vuln-scan" "--script vuln -p$openPorts" &

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

nmapRemainingFullPortScan $openPorts &

# FFUF scan -----------------------------------------------------------------

if [[ ','$openPorts',' =~ ',80,' ]]; then
    echo '[*] Enumerating dirs,files,dns on the webserver '
    ffuf -u "http://$ip/FUZZ" -w "./../wordlist/dirs.txt" -s -mc 200-299 >> "./2-ffuf/dir.txt" &
    ffuf -u "http://$ip" -w "./../wordlist/subdomains.txt" -H "Host: FUZZ.$ip" -fc 301 -s >> "./2-ffuf/subdomains.txt" &
fi

# Nikto scan -----------------------------------------------------------------

if [[ ','$openPorts',' =~ ',80,' ]]; then
    nikto -h $ip > './3-nikto/scan.txt' &
fi

#  -----------------------------------------------------------------

#  -----------------------------------------------------------------


wait
echo 'Exiting Ezrecon.'
###################################################################################
