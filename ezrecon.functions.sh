function initScript() {
    local ip=$1

    if [[ "$ip" == "" ]]; then
        echo -e 'Invalid usage: Provide IP Address or URL\n./ezrecon.sh <ip/url>'
        exit 1
    fi

    mkdir recon-"$ip"
    cd recon-"$ip" || exit
    mkdir 1-nmap 2-ffuf 
}

function nmapScan() {
    local scanName=$1
    local options=$2

    echo "[+] Initialized nmap $scanName scan..."

    echo -e 'nmap '$options' '$ip' -T5 \n' > "./1-nmap/$scanName.txt"
    nmap $options $ip -T5 >> "./1-nmap/$scanName.txt"

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

    nmapScan "8-new-remaining-general-scan" "-sCSV -p$newPorts" &
    nmapScan "9-new-remaining-vul-scan" "--script vuln -p$newPorts" &
    nmapScan "10-new-remaining-aggressive-scan" "-A -p$newPorts" &
    nmapScan "11-new-remaining-version-scan" "-sV -p$newPorts" &


}

function ffufScan() {
    local scanName=$1
    local wordlist=$2

    echo "[+] Initialized nmap $scanName scan..."

    echo "ffuf -u http://$ip/FUZZ -w $wordlist " > "./1-nmap/$scanName.txt"
    ffuf -u "http://$ip/FUZZ" -w $wordlist | tee -a "./ffuf/$scanName.txt"

    echo "[-] Completed nmap $scanName scan"
}