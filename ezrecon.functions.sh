function initScript() {
    local ip=$1

    if [[ "$ip" == "" ]]; then
        echo -e 'Invalid usage: Provide IP Address or URL\n./ezrecon.sh <ip/url>'
        exit 1
    fi

    mkdir recon-"$ip"
    cd recon-"$ip" || exit
    mkdir nmap ffuf 
}

function nmapScan() {
    local scanName=$1
    local options=$2

    echo "[+] Initialized nmap $scanName scan..."

    echo -e 'nmap '$options' '$ip' -T5 \n' > "./nmap/$scanName.txt"
    nmap $options $ip -T5 >> "./nmap/$scanName.txt"

    echo "[-] Completed nmap $scanName scan"
}

function getOpenPortList() {
    local portList=$(cat ./nmap/1-full-port-scan.txt | grep -E "^[0-9]+/.*open" | awk '{print $1}' | cut -d'/' -f1 | tr '\n' ',')
    portList="${portList%,}"
    echo $portList
}

function ffufScan() {
    local scanName=$1
    local wordlist=$2

    echo "[+] Initialized nmap $scanName scan..."

    echo "ffuf -u http://$ip/FUZZ -w $wordlist " > "./nmap/$scanName.txt"
    ffuf -u "http://$ip/FUZZ" -w $wordlist | tee -a "./ffuf/$scanName.txt"

    echo "[-] Completed nmap $scanName scan"
}