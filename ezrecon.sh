#!/bin/bash

function init() {
    if [[ "$1" == "" ]]; then
        echo 'Invalid usage: ./autorecon.sh $ip'
        exit 1
    fi

    mkdir recon-"$1"
    cd recon-"$1" || exit
    mkdir nmap
    mkdir ffuf
}

# Starting of Nmap Scan ----------------------------------------------
function nmapFullPortScan() {
    echo '[+] Initialized nmap full port scan...'
    nmap -p- "$1" | tee ./nmap/full-port-scan.txt
    echo '[-] Completed nmap full port scan'
}

function nmapGeneralScriptScan() {
    echo '[+] Initialized nmap general script scan...'
    nmap -sC "$1" | tee ./nmap/general-script-scan.txt
    echo '[-] Completed nmap general script scan'
}

function nmapVulnScriptScan() {
    echo '[+] Initialized nmap vuln script scan...'
    nmap --script vuln "$1" | tee ./nmap/vuln-script-scan.txt
    echo '[-] Completed nmap vuln script scan'
}

# Starting of FFUF Scan ----------------------------------------------
function ffufScan() {
    echo '[+] Initialized ffuf file scan...'
    ffuf -u "http://$1/FUZZ" -w ./ffuf-wordlist.txt | tee ./ffuf/general-scan.txt
    echo '[-] Completed ffuf scan'
}

# Set a trap to handle script termination
trap 'echo "Terminating..."; exit 1' SIGINT SIGTERM

init "$1"

# Nmap scans
nmapFullPortScan "$1" &
nmapGeneralScriptScan "$1" &
nmapVulnScriptScan "$1" & 

# FFUF scan
ffufScan "$1" &

# Wait for all background jobs to finish
wait

echo 'All scans completed.'
