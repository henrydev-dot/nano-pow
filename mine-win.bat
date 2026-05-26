@echo off
rem ==============================================================================
rem  NANO POW // WINDOWS MINER BOOTSTRAPPER & AUTO-LAUNCHER
rem  Compatible with Geth v1.10.x and above
rem ==============================================================================
setlocal EnableDelayedExpansion

set DATADIR=nano-node-data
set GENESIS=genesis.json
set CHAIN_ID=78910

cls
echo ====================================================================
echo                     N A N O   P O W   N E T W O R K                 
echo                MINER LAUNCHER FOR WINDOWS (CPU MINING)              
echo ====================================================================
echo.

rem 1. Check if Geth is installed or present locally
echo [*] Step 1: Checking Go-Ethereum (geth.exe) installation...
set GETH_CMD=geth
if exist geth.exe (
    set GETH_CMD=.\geth.exe
    echo [+] Found local geth.exe in directory.
) else (
    where geth >nul 2>nul
    if !errorlevel! equ 0 (
        echo [+] Found system-wide geth installation.
    ) else (
        echo [!] WARNING: geth.exe is not found locally or in PATH.
        echo [*] Auto-downloading compatible Geth v1.10.26 for Windows x64...
        
        powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Write-Host 'Connecting to Ethereum builds server...'; Invoke-WebRequest -Uri 'https://gethstore.blob.core.windows.net/builds/geth-windows-amd64-1.10.26-e5eb32ac.zip' -OutFile 'geth.zip'"
        if not exist geth.zip (
            echo [-][ERROR] Failed to download geth.zip. Please download it manually from:
            echo     https://geth.ethereum.org/downloads
            pause
            exit /b 1
        )
        
        echo [*] Extracting Geth executable...
        powershell -Command "Expand-Archive -Path 'geth.zip' -DestinationPath 'temp_geth' -Force"
        if exist temp_geth\geth-windows-amd64-1.10.26-e5eb32ac\geth.exe (
            move /y temp_geth\geth-windows-amd64-1.10.26-e5eb32ac\geth.exe .\geth.exe >nul
        ) else (
            echo [-][ERROR] Extraction failed or folder structure unexpected.
            pause
            exit /b 1
        )
        
        echo [*] Cleaning up temporary files...
        del /q geth.zip >nul 2>nul
        rmdir /s /q temp_geth >nul 2>nul
        
        set GETH_CMD=.\geth.exe
        echo [+][SUCCESS] Geth has been successfully downloaded and placed in the current directory!
    )
)
echo.

rem 2. Check Genesis File
if not exist !GENESIS! (
    echo [-][ERROR] genesis.json is missing in the current directory.
    echo     Make sure you run this script from the root of the nano-pow folder.
    pause
    exit /b 1
)

rem 3. Genesis Initialization
if not exist !DATADIR!\geth (
    echo [*] Step 2: Initializing NANO PoW Genesis block...
    !GETH_CMD! --datadir "!DATADIR!" init "!GENESIS!"
    if !errorlevel! neq 0 (
        echo [-][ERROR] Failed to initialize genesis block.
        pause
        exit /b 1
    )
    echo [+][SUCCESS] Genesis block successfully seeded.
) else (
    echo [*] Step 2: Genesis block already initialized.
)
echo.

rem 4. Wallet Setup (Coinbase Address)
echo [*] Step 3: Wallet Configuration (Where mining rewards will be sent)
echo     1) Use an existing EVM/MetaMask wallet address
echo     2) Create a brand new local wallet using geth
set /p WALLET_OPT="Select option (1 or 2, default: 1): "

set WALLET_ADDRESS=
if "!WALLET_OPT!"=="2" (
    echo.
    echo [!] Creating a new local account.
    echo     Please enter a secure password when prompted. Save it safely!
    echo     ----------------------------------------------------------
    !GETH_CMD! --datadir "!DATADIR!" account new
    
    echo.
    echo     Please copy your newly generated address listed above.
    echo     It is printed as: Public address of the key: 0x...
    echo     ----------------------------------------------------------
    set /p WALLET_ADDRESS="Paste your newly created wallet address (0x...): "
    
    echo.
    echo [!] IMPORTANT: The keystore file is located in "!DATADIR!\keystore\"
    echo     DO NOT LOSE YOUR PASSWORD AND BACK UP THIS FOLDER!
)

if "!WALLET_ADDRESS!"=="" (
    :wallet_loop
    echo.
    set /p USER_ADDR="Enter your EVM / MetaMask public address (0x...): "
    
    rem Simple validation: check if starts with 0x and length is 42
    set CHECK_ADDR=!USER_ADDR!
    if "!CHECK_ADDR:~0,2!"=="0x" (
        set WALLET_ADDRESS=!CHECK_ADDR!
    ) else (
        echo [-] Invalid address format. EVM address must start with 0x.
        goto wallet_loop
    )
)
echo.

rem 5. Miner CPU Threads Setup
echo [*] Step 4: Configure CPU Mining Threads
set /p THREADS_INPUT="Enter the number of CPU threads to use for mining (default: 2): "
if "!THREADS_INPUT!"=="" (
    set THREADS=2
) else (
    set THREADS=!THREADS_INPUT!
)
echo.

rem 6. Network Peer Sync (Bootnode)
echo [*] Step 5: Network Connection Setup
echo     To sync with other nodes, you need to connect to the main bootnode.
echo     Get the bootnode enode URL from the network host.
echo     Example format: enode://pubkey@VDS_IP:30303
echo     (Press Enter to skip bootnode entry and run as a standalone node)
echo     ----------------------------------------------------------
set /p ENODE_URL="Enter VDS ENODE URL: "

set BOOTNODE_ARG=
if not "!ENODE_URL!"=="" (
    set BOOTNODE_ARG=--bootnodes="!ENODE_URL!"
    echo [+] Bootnode configured.
) else (
    echo [!] Running node in standalone/isolated mode (No peer connection).
)
echo.

rem 7. Start Mining!
echo ====================================================================
echo   NANO POW PROTOCOL BOOTING UP
echo   Chain ID:       !CHAIN_ID!
echo   Rewards Wallet: !WALLET_ADDRESS!
echo   CPU Threads:    !THREADS!
echo   Network RPC:    https://rpc.nan0.cash
echo ====================================================================
echo [*] Launching geth miner...
echo.

!GETH_CMD! ^
    --datadir "!DATADIR!" ^
    --networkid "!CHAIN_ID!" ^
    --port 30303 ^
    --mine ^
    --miner.threads=!THREADS! ^
    --miner.etherbase="!WALLET_ADDRESS!" ^
    --http ^
    --http.addr "127.0.0.1" ^
    --http.port 8545 ^
    --http.corsdomain "*" ^
    --http.vhosts "*" ^
    --http.api "eth,net,web3,personal,miner,txpool" ^
    --allow-insecure-unlock ^
    !BOOTNODE_ARG!

pause
