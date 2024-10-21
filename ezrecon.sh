#!/bin/bash

function init() {
    if [[ "$1" == "" ]]; then
        echo 'Invalid useage: ./autorecon.sh $ip'
        exit 1
    fi

    mkdir recon-$1
    cd recon-$1
    mkdir nmap
    mkdir ffuf
}

#  Starting of Nmap Scan ----------------------------------------------
function nmapFullPortScan() {
    echo '[+] Initialised nmap full port scan...'
    nmap -p- $1 | tee ./nmap/full-port-scan.txt &
    echo '[-] Completed nmap full port scan'
}

function nmapGeneralScriptScan() {
    echo '[+] Initialised nmap general script scan...'
    nmap -sCSV $1 | tee ./nmap/general-script-scan.txt &
    echo '[-] Completed nmap general script scan'
}

function nmapVulnScriptScan() {
    echo '[+] Initialised nmap vuln script scan...'
    nmap --script vuln $1 | tee ./nmap/vuln-script-scan.txt &
    echo '[-] Completed nmap vuln script scan'
}
# Starting of FFUF Scan ----------------------------------------------
function ffufBigFileScan() {
    echo '[+] Initialised ffuf big file scan...'
    nmap --script vuln $1 | tee ./nmap/vuln-script-scan.txt &
    echo '[-] Completed nmap vuln script scan'
}


init
# Nmap 
nmapFullPortScan &
nmapGeneralScriptScan &
nmapVulnScriptScan & 
# Fuff

