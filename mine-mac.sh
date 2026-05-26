#!/bin/bash
# ==============================================================================
#  NANO POW // MAC-OS MINER BOOTSTRAPPER & AUTO-LAUNCHER
#  Compatible with Geth v1.10.x and above
# ==============================================================================

# Terminal Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0;0m' # No Color

# Directories and Configs
DATADIR="./nano-node-data"
GENESIS="./genesis.json"
CHAIN_ID=78910

clear
echo -e "${CYAN}====================================================================${NC}"
echo -e "${CYAN}                    N A N O   P O W   N E T W O R K                 ${NC}"
echo -e "${CYAN}               MINER LAUNCHER FOR MAC-OS (CPU MINING)               ${NC}"
echo -e "${CYAN}====================================================================${NC}"
echo ""

# 1. Check if Geth is installed
echo -e "[*] Step 1: Checking Go-Ethereum (geth) installation..."
if ! command -v geth >/dev/null 2>&1; then
    echo -e "${YELLOW}[!] WARNING: geth is not installed on this system.${NC}"
    echo -e "[*] Checking if Homebrew is available to install Geth automatically..."
    if command -v brew >/dev/null 2>&1; then
        echo -e "[*] Homebrew found. Installing Go-Ethereum via brew..."
        brew tap ethereum/ethereum
        brew install ethereum
        if ! command -v geth >/dev/null 2>&1; then
            echo -e "${RED}[-][ERROR] Geth installation failed. Please install it manually:${NC}"
            echo -e "    brew tap ethereum/ethereum && brew install ethereum"
            exit 1
        fi
        echo -e "${GREEN}[+][SUCCESS] Geth has been successfully installed!${NC}"
    else
        echo -e "${RED}[-][ERROR] Homebrew is not found on your system.${NC}"
        echo -e "    Please install Homebrew first (https://brew.sh) or manually"
        echo -e "    download go-ethereum binary from: https://geth.ethereum.org/downloads"
        exit 1
    fi
else
    GETH_VERSION=$(geth version | grep -Ei "version:" | head -n 1)
    echo -e "${GREEN}[+][SUCCESS] Geth is installed: $GETH_VERSION${NC}"
fi
echo ""

# 2. Check Genesis File
if [ ! -f "$GENESIS" ]; then
    echo -e "${RED}[-][ERROR] genesis.json is missing in the current directory.${NC}"
    echo -e "    Make sure you run this script from the root of the nano-pow folder.${NC}"
    exit 1
fi

# 3. Genesis Initialization
if [ ! -d "$DATADIR/geth" ]; then
    echo -e "[*] Step 2: Initializing NANO PoW Genesis block..."
    geth --datadir "$DATADIR" init "$GENESIS"
    if [ $? -ne 0 ]; then
        echo -e "${RED}[-][ERROR] Failed to initialize genesis block.${NC}"
        exit 1
    fi
    echo -e "${GREEN}[+][SUCCESS] Genesis block successfully seeded.${NC}"
else
    echo -e "[*] Step 2: Genesis block already initialized."
fi
echo ""

# 4. Wallet Setup (Coinbase Address)
echo -e "[*] Step 3: Wallet Configuration (Where mining rewards will be sent)"
echo -e "    1) Use an existing EVM/MetaMask wallet address"
echo -e "    2) Create a brand new local wallet using geth"
printf "Select option (1 or 2, default: 1): "
read -r WALLET_OPT

WALLET_ADDRESS=""
if [ "$WALLET_OPT" = "2" ]; then
    echo ""
    echo -e "${YELLOW}[!] Creating a new local account.${NC}"
    echo -e "    Please enter a secure password when prompted. Save it safely!"
    echo -e "    ----------------------------------------------------------${NC}"
    geth --datadir "$DATADIR" account new
    
    # Extract the new address from keystore
    # It lists accounts with geth account list
    WALLET_ADDRESS=$(geth --datadir "$DATADIR" account list | head -n 1 | awk -F'[{}]' '{print $2}')
    
    if [ -z "$WALLET_ADDRESS" ]; then
        echo -e "${RED}[-][ERROR] Failed to extract the newly created address.${NC}"
        echo -e "    Reverting to manual entry."
        WALLET_OPT="1"
    else
        WALLET_ADDRESS="0x$WALLET_ADDRESS"
        echo -e "    ----------------------------------------------------------"
        echo -e "${GREEN}[+][SUCCESS] Created new wallet address: $WALLET_ADDRESS${NC}"
        echo -e "${YELLOW}[!] IMPORTANT: The keystore file is located in:${NC}"
        echo -e "    $DATADIR/keystore/"
        echo -e "${YELLOW}    DO NOT LOSE YOUR PASSWORD AND BACK UP THIS FOLDER!${NC}"
    fi
fi

if [ -z "$WALLET_ADDRESS" ] || [ "$WALLET_OPT" = "1" ] || [ "$WALLET_OPT" = "" ]; then
    while true; do
        echo ""
        printf "Enter your EVM / MetaMask public address (0x...): "
        read -r USER_ADDR
        # Clean address
        USER_ADDR=$(echo "$USER_ADDR" | xargs)
        
        # Simple validation
        if [[ "$USER_ADDR" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
            WALLET_ADDRESS="$USER_ADDR"
            break
        else
            echo -e "${RED}[-] Invalid EVM address. Must be a 42-character hex starting with 0x.${NC}"
        fi
    done
fi
echo ""

# 5. Miner CPU Threads Setup
echo -e "[*] Step 4: Configure CPU Mining Threads"
printf "Enter the number of CPU threads to use for mining (default: 2): "
read -r THREADS_INPUT
if [ -z "$THREADS_INPUT" ]; then
    THREADS=2
else
    THREADS=$THREADS_INPUT
fi
echo ""

# 6. Network Peer Sync (Bootnode)
echo -e "[*] Step 5: Network Connection Setup"
echo -e "    To sync with other nodes, you need to connect to the main bootnode."
echo -e "    Get the bootnode enode URL from the network host."
echo -e "    Example format: enode://pubkey@VDS_IP:30303"
echo -e "    (Press Enter to skip bootnode entry and run as a standalone node)"
echo -e "    ----------------------------------------------------------"
printf "Enter VDS ENODE URL: "
read -r ENODE_URL
ENODE_URL=$(echo "$ENODE_URL" | xargs)

BOOTNODE_ARG=""
if [ -n "$ENODE_URL" ]; then
    BOOTNODE_ARG="--bootnodes=$ENODE_URL"
    echo -e "${GREEN}[+] Bootnode configured.${NC}"
else
    echo -e "${YELLOW}[!] Running node in standalone/isolated mode (No peer connection).${NC}"
fi
echo ""

# 7. Start Mining!
echo -e "${CYAN}====================================================================${NC}"
echo -e "  NANO POW PROTOCOL BOOTING UP"
echo -e "  Chain ID:       $CHAIN_ID"
echo -e "  Rewards Wallet: $WALLET_ADDRESS"
echo -e "  CPU Threads:    $THREADS"
echo -e "  Network RPC:    https://rpc.orisdao.com"
echo -e "${CYAN}====================================================================${NC}"
echo -e "[*] Launching geth miner..."
echo ""

# Run geth miner
exec geth \
    --datadir "$DATADIR" \
    --networkid "$CHAIN_ID" \
    --port 30303 \
    --mine \
    --miner.threads="$THREADS" \
    --miner.etherbase="$WALLET_ADDRESS" \
    --http \
    --http.addr "127.0.0.1" \
    --http.port 8545 \
    --http.corsdomain "*" \
    --http.vhosts "*" \
    --http.api "eth,net,web3,personal,miner,txpool" \
    --allow-insecure-unlock \
    $BOOTNODE_ARG
