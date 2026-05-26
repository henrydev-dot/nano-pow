# NANO POW // PURE EVM-COMPATIBLE POW BLOCKCHAIN

Welcome to **NANO POW**, a purely fair-launch, high-performance, EVM-compatible Proof-of-Work (PoW) blockchain network. 

Built on a zero-pre-mine policy, every single NANO token in circulation is generated purely through CPU or GPU mining. There are no allocations for founders, advisors, or venture capitalists. 

This repository contains the official genesis files, bootstrap configurations, and automated mining scripts for **macOS** and **Windows** to help you join the network instantly.

---

## NETWORK STATISTICS & TECHNICAL DETAILS

- **Network Name:** NANO POW Chain
- **Chain ID:** `78910`
- **Token Symbol:** `NANO`
- **Total Supply Cap:** `110,000,000 NANO`
- **Initial Block Reward:** `260 NANO` (Halves every `211,538` blocks)
- **Uncle Rewards:** Disabled (Strict fair supply curves)
- **Target Block Time:** 13-15 seconds
- **Gas Limit:** `30,000,000`
- **Genesis Difficulty:** `1024` (0x400) - CPU miner friendly
- **Public RPC Endpoint:** `https://rpc.nan0.cash`
- **Public Block Explorer:** `http://blocks.nan0.cash`

---

## METAMASK INTEGRATION

You can manually add the NANO POW Chain to MetaMask using the following details:

- **Network Name:** NANO POW Chain
- **RPC URL:** `https://rpc.nan0.cash`
- **Chain ID:** `78910`
- **Currency Symbol:** `NANO`
- **Block Explorer URL:** `http://blocks.nan0.cash`

Alternatively, you can visit the [NANO Block Explorer](http://blocks.nan0.cash) and click **ADD NANO CHAIN** to automatically add and connect your MetaMask wallet.

---

## QUICK-START CPU MINING REHBERI (TURKISH & ENGLISH)

### A. MAC-OS MINING
We have provided an automated, interactive terminal miner helper.

1. Open your terminal and navigate to this repository:
   ```bash
   cd nano-pow
   ```
2. Run the macOS miner bootstrapper:
   ```bash
   ./mine-mac.sh
   ```
3. The script will:
   - Check and automatically install Go-Ethereum (`geth`) via Homebrew if it is missing.
   - Seed the `genesis.json` configuration block.
   - Ask if you want to use an existing MetaMask address or generate a secure new local key via geth.
   - Ask you to enter the remote VDS Bootnode Enode address (or press Enter to run a standalone node).
   - Prompt you to specify how many CPU threads to dedicate to mining.
   - Instantly boot Geth and begin CPU mining to your chosen address.

---

### B. WINDOWS MINING
We have provided an automated batch launcher that self-bootstraps Geth.

1. Double-click the file **`mine-win.bat`** or run it from Command Prompt:
   ```cmd
   mine-win.bat
   ```
2. The script will:
   - Check for `geth.exe` locally. If missing, it uses PowerShell to automatically download and extract compatible Go-Ethereum v1.10.26.
   - Seed the genesis block automatically.
   - Prompt you to paste your EVM address (e.g. MetaMask) or generate a new key locally.
   - Ask for the VDS Bootnode Enode URL (or press Enter to run standalone).
   - Boot geth and launch CPU mining on your chosen thread count.

---

### C. LINUX / MANUAL MINING

To mine manually on Linux or standard Unix terminals, apply the following steps:

1. **Install Geth:**
   - Ubuntu/Debian:
     ```bash
     sudo add-apt-repository -y ppa:ethereum/ethereum
     sudo apt-get update
     sudo apt-get install ethereum -y
     ```
2. **Initialize Genesis:**
   ```bash
   geth --datadir ./nano-node-data init genesis.json
   ```
3. **Start Node and CPU Miner:**
   Replace `<YOUR_WALLET_ADDRESS>` with your real MetaMask address (e.g., `0xca8...`) and `<BOOTNODE_ENODE_URL>` with the remote bootnode URL.
   ```bash
   geth \
     --datadir ./nano-node-data \
     --networkid 78910 \
     --port 30303 \
     --mine \
     --miner.threads=2 \
     --miner.etherbase="<YOUR_WALLET_ADDRESS>" \
     --bootnodes="<BOOTNODE_ENODE_URL>" \
     --http \
     --http.addr "127.0.0.1" \
     --http.port 8545 \
     --http.corsdomain "*" \
     --http.api "eth,net,web3,personal,miner,txpool" \
     --allow-insecure-unlock
   ```

---

## REMOTE SYNCING & BOOTNODE DISCOVERY

For local miners to sync blocks and join the main network, they must connect to the primary node (VDS).

### How to Find Your Node's Enode (For Node Hosts)
If you are running the primary node on your VDS, you can fetch your `enode://` link by executing the following command in your VDS terminal:
```bash
docker logs geth-node 2>&1 | grep enode://
```
The output will display a connection string like this:
```text
enode://d6d84a7e93bfa09930f78...@[VDS_PUBLIC_IP]:30303
```
*Note: Make sure to replace any internal IP (like `127.0.0.1` or `172.x.x.x`) in the enode URL with your VDS's real raw public IP before giving it to external miners!*

---

## TWITTER / X LAUNCH ANNOUNCEMENT TEMPLATE (TWITTER/X PAYLAŞIM TASLAĞI)

Ready-to-use launch text to announce **NANO POW** to the community:

### Option 1: Turkish / Türkçe (Anarşik & Güçlü)
```text
Sıfır Pre-mine. Sıfır VC. Tamamen adil lansman! 🛠️

EVM uyumlu, saf Proof of Work (PoW) blockchain ağımız NANO POW yayında! 
Toplam arz 110M ile sınırlı, ilk blok ödülü 260 NANO! Her şey madenciler için.

Hemen CPU/GPU ile kazmaya başlayın, cüzdanınızı bağlayın:
🌐 Explorer & MetaMask Ekleme: http://blocks.nan0.cash
💻 Madenci Kurulum Seti (Windows & macOS Scriptler): https://github.com/henrydev-dot/nano-pow
⚡ RPC Adresi: https://rpc.nan0.cash (ChainID: 78910)

Kendi cüzdanını oluştur, genesis bloğunu eşle ve tarihe ortak ol! 🚀 #NANOPow #PoW #Mining #Web3 #EVM
```

### Option 2: English (Punchy & Direct)
```text
Zero Pre-mine. Zero VCs. 100% Fair Launch! 🛠️

NANO POW is officially live—a pure EVM-compatible Proof of Work (PoW) network. 
Max supply is capped at 110,000,000 NANO. Initial block reward is 260 NANO.

Mine directly on your local computer using CPU/GPU in minutes:
🌐 Block Explorer & 1-Click MetaMask Add: http://blocks.nan0.cash
💻 Windows & macOS Auto-Miner Scripts: https://github.com/henrydev-dot/nano-pow
⚡ RPC Server: https://rpc.nan0.cash (ChainID: 78910)

Generate your keys, sync the genesis, and start accumulating NANO today. 🚀 #NANOPow #EVM #ProofOfWork #Mining
```

---

## REPOSITORY LICENSING
Licensed under the [MIT License](LICENSE). Feel free to fork, customize, and adapt this PoW mining kit for your own networks!
