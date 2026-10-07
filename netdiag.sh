#!/bin/bash

# ============================================================
# Linux Network Diagnostic Tool
# ============================================================

LOG_DIR="logs"
LOG_FILE="$LOG_DIR/netdiag.log"
INTERNET_TARGET="8.8.8.8"

# ------------------------------------------------------------
# Help
# ------------------------------------------------------------

if [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
    echo "Linux Network Diagnostic Tool"
    echo
    echo "Usage:"
    echo "  ./netdiag.sh          Run network diagnostics"
    echo "  ./netdiag.sh --help   Show this help"
    exit 0
fi

# ------------------------------------------------------------
# Dependency Check
# ------------------------------------------------------------

REQUIRED_COMMANDS=("ip" "ping" "awk" "grep" "sed" "ss" "resolvectl" "dig")

for COMMAND in "${REQUIRED_COMMANDS[@]}"
do
    if ! command -v "$COMMAND" > /dev/null 2>&1
    then
        echo "ERROR: Required command '$COMMAND' is not installed."
        exit 1
    fi
done

# ------------------------------------------------------------
# Prepare Logging
# ------------------------------------------------------------

mkdir -p "$LOG_DIR"

# ------------------------------------------------------------
# Network Information
# ------------------------------------------------------------

INTERFACE=$(ip route | grep '^default' | awk '{print $5}')

if [ -z "$INTERFACE" ]
then
    echo "ERROR: No active network interface found."
    exit 1
fi

IP_ADDRESS=$(ip -4 addr show "$INTERFACE" |
    grep 'inet ' |
    awk '{print $2}' |
    cut -d/ -f1 |
    head -n 1)

STATE=$(ip link show "$INTERFACE" |
    grep -o 'state [A-Z]*' |
    awk '{print $2}')

GATEWAY=$(ip route |
    grep '^default' |
    awk '{print $3}' |
    head -n 1)

# ------------------------------------------------------------
# DNS Information
# ------------------------------------------------------------

DNS_SERVER=$(resolvectl status |
    grep 'DNS Servers' |
    head -n 1 |
    awk '{print $3}')

if [ -z "$DNS_SERVER" ]
then
    DNS_SERVER="Unknown"
fi

# ------------------------------------------------------------
# Display Header
# ------------------------------------------------------------

echo
echo "========================================"
echo "       LINUX NETWORK DIAGNOSTIC"
echo "========================================"
echo

# ------------------------------------------------------------
# 1. Network Interface
# ------------------------------------------------------------

echo "[1] Network Interface"
echo "    Interface : $INTERFACE"
echo "    State     : $STATE"
echo "    IP        : ${IP_ADDRESS:-Unknown}"

# ------------------------------------------------------------
# 2. Default Gateway
# ------------------------------------------------------------

echo
echo "[2] Default Gateway"

if [ -z "$GATEWAY" ]
then
    GATEWAY_STATUS="UNAVAILABLE"
    echo "    Gateway : Unknown"
    echo "    Status  : $GATEWAY_STATUS"
else
    echo "    Gateway : $GATEWAY"

    if ping -c 1 -W 2 "$GATEWAY" > /dev/null 2>&1
    then
        GATEWAY_STATUS="REACHABLE"
    else
        GATEWAY_STATUS="UNREACHABLE"
    fi

    echo "    Status  : $GATEWAY_STATUS"
fi

# ------------------------------------------------------------
# 3. DNS
# ------------------------------------------------------------

echo
echo "[3] DNS"
echo "    DNS Server : $DNS_SERVER"

if dig google.com +short > /dev/null 2>&1
then
    DNS_STATUS="WORKING"
else
    DNS_STATUS="FAILED"
fi

echo "    Status     : $DNS_STATUS"

# ------------------------------------------------------------
# 4. Internet Connectivity
# ------------------------------------------------------------

echo
echo "[4] Internet Connectivity"
echo "    Target : $INTERNET_TARGET"

PING_RESULT=$(ping -c 1 -W 2 "$INTERNET_TARGET" 2>/dev/null)

if [ $? -eq 0 ]
then
    INTERNET_STATUS="ONLINE"

    LATENCY=$(echo "$PING_RESULT" |
        grep 'time=' |
        sed -n 's/.*time=\([0-9.]*\).*/\1/p')
else
    INTERNET_STATUS="OFFLINE"
    LATENCY="N/A"
fi

echo "    Status : $INTERNET_STATUS"
echo "    Latency: ${LATENCY} ms"

# ------------------------------------------------------------
# 5. Local Port Check
# ------------------------------------------------------------

echo
echo "[5] Local Port Check"

check_port()
{
    PORT=$1
    SERVICE=$2

    if ss -lnt | awk '{print $4}' | grep -q ":$PORT$"
    then
        echo "    $SERVICE ($PORT) : OPEN"
    else
        echo "    $SERVICE ($PORT) : CLOSED"
    fi
}

check_port 22 "SSH"
check_port 80 "HTTP"
check_port 443 "HTTPS"

# ------------------------------------------------------------
# 6. Overall Status
# ------------------------------------------------------------

if [ "$STATE" = "UP" ] &&
   [ "$GATEWAY_STATUS" = "REACHABLE" ] &&
   [ "$DNS_STATUS" = "WORKING" ] &&
   [ "$INTERNET_STATUS" = "ONLINE" ]
then
    OVERALL_STATUS="HEALTHY"
else
    OVERALL_STATUS="WARNING"
fi

echo
echo "========================================"
echo "Overall Status : $OVERALL_STATUS"
echo "========================================"

# ------------------------------------------------------------
# Logging
# ------------------------------------------------------------

{
    echo "$(date '+%Y-%m-%d %H:%M:%S')"
    echo "Interface : $INTERFACE"
    echo "IP        : ${IP_ADDRESS:-Unknown}"
    echo "Gateway   : $GATEWAY_STATUS"
    echo "DNS       : $DNS_STATUS"
    echo "Internet  : $INTERNET_STATUS"
    echo "Latency   : ${LATENCY} ms"
    echo "Overall   : $OVERALL_STATUS"
    echo "----------------------------------------"
} >> "$LOG_FILE"
