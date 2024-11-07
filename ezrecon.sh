#!/bin/bash
source ./ezrecon.functions.sh
##################[Set a trap to handle script termination]##################
trap 'echo "Terminating..."; exit 1' SIGINT SIGTERM

ip=$1
initScript $ip

nmapScan "full-port-scan" "-p-" 
openPorts=$(getOpenPortList)

nmapScan "1-version-scan" "-sV -p$openPorts" &
nmapScan "1-general-scan" "-sCSV -p$openPorts" &
nmapScan "2-vul-scan" "--script vuln -p$openPorts" &
nmapScan "3-aggressive-scan" "-A -p$openPorts" &

# ffufScan "" ""

wait
echo 'All scans completed.'
###################################################################################
