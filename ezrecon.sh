#!/bin/bash
source ./ezrecon.functions.sh
##################[Set a trap to handle script termination]##################
trap 'echo "Terminating..."; exit 1' SIGINT SIGTERM

ip=$1
initScript $ip

nmapScan "1-common-ports-scan" "-v" 
openPorts=$(getOpenPortList "1-common-ports-scan")

nmapScan "2-general-scan" "-sCSV -p$openPorts" &
nmapScan "3-vul-scan" "--script vuln -p$openPorts" &
nmapScan "4-aggressive-scan" "-A -p$openPorts" &
nmapScan "5-version-scan" "-sV -p$openPorts" &

nmapRemainingFullPortScan $openPorts &
# ffufScan "" ""

wait
echo 'All scans completed.'
###################################################################################
