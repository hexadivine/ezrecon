function initScript() {
    local ip=$1

    if [[ "$ip" == "" ]]; then
        echo -e 'Invalid usage: Provide IP Address or URL\n./ezrecon.sh <ip/url>'
        exit 1
    fi

    mkdir recon-"$ip"
    cd recon-"$ip"
    mkdir -p 1-nmap/ports

    gnome-terminal -- ranger .
}

function nmapScan() {
    local scanName=$1
    local options=$2

    echo "[+] Initialized nmap $scanName scan..."

    echo -e 'nmap '$options' '$ip' -T5 \n' > "./1-nmap/$scanName.txt"
    nmap $options $ip -T5 >> "./1-nmap/$scanName.txt"

    echo "[-] Completed nmap $scanName scan"
}

function nmapPortScriptScan() {
    local portNum=$1
    local portName=$2

    echo "[+] Initialized nmap script scan for $portName on port $portName..."

    echo -e 'nmap --script="'$portName'* not auth and not broadcast and not brute and not dos and not exploit and not external and not fuzzer and not intrusive and not malware" -p'$portNum' '$ip' -T5 \n' > "./1-nmap/ports/$portName.txt"
    nmap --script="$portName* and not auth and not broadcast and not brute and not dos and not exploit and not external and not fuzzer and not intrusive and not malware" -p"$portNum"  $ip -T5 >> "./1-nmap/ports/$portName.txt"

    echo "[-] Completed nmap $scanName scan"
}

function getOpenPortList() {
    local fileName=$1
    local portList=$(cat ./1-nmap/$fileName.txt | grep -E "^[0-9]+/.*open" | awk '{print $1}' | cut -d'/' -f1 | tr '\n' ',')
    portList="${portList%,}"
    echo $portList
}

function nmapRemainingFullPortScan() {
    local knownPorts=$1
    nmapScan "6-full-port-scan" "-v -p- --host-timeout 60m"
    local openPorts=$(getOpenPortList "6-full-port-scan")

    for openPort in $(echo $openPorts | tr ',' '\n'); do
        if [[ ! ",$knownPorts," =~ ",$openPort,"  ]]; then  
            echo $openPort >> './1-nmap/7-new-ports.txt'
        fi
    done

    if [[ ! -f "./1-nmap/7-new-ports.txt" ]]; then
        echo '[x] New ports are not found'
        return -1
    fi

    echo '[+] Found remaining ports...'

    local newPorts=$(cat "./1-nmap/7-new-ports.txt" | tr '\n' ',')
    newPorts="${newPorts%,}"

    nmapScan "8-new-ports-general-scan" "-sCV -p$newPorts" &
    # nmapScan "9-new-ports-script-scan" "--script default,discovery,safe,version,vuln -p$newPorts" &
    nmapScan "9-new-ports-aggressive-scan" "-A -p$newPorts" &
    # nmapScan "11-new-remaining-version-scan" "-sV -p$newPorts" &

}
