# MEMAO Token Factory

This is the open-source Factory contract used by the MEMAO Platform to deploy ERC20 tokens.

---

## Project Structure

```text
MEMAO-Factory/
├── lib/                  # External dependencies (e.g., OpenZeppelin)
├── src/
│   └── TokenFactory.sol  # Factory contract
├── test/                 # Optional tests
├── foundry.toml          # Foundry configuration
├── .gitignore
└── README.md
```

---

## Prerequisites

- Foundry installed — https://book.getfoundry.sh/
- Ethereum RPC provider (Infura / Alchemy / local node)
- Wallet funded with ETH for deployment

---

## Usage

### 1. Clone repository

```bash
git clone https://github.com/<your-username>/MEMAO-Factory.git
cd MEMAO-Factory
```

### 2. Compile

```bash
forge build
```

### 3. Deploy factory contract

Before deploying, ensure:

- **RPC_URL** – RPC endpoint  
- **PRIVATE_KEY** – deployer private key  
- **PLATFORM_WALLET_ADDRESS** – address to collect deployment fees  

> ✅ Recommended: Use environment variables

```bash
export RPC_URL="https://sepolia.infura.io/v3/YOUR_PROJECT_ID"
export PRIVATE_KEY="0xabc...."
export PLATFORM_WALLET_ADDRESS="0xPlatformWallet"
```

#### Deploy

```bash
forge script script/DeployFactory.s.sol:DeployFactory \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --sig "run(address)" \
  $PLATFORM_WALLET_ADDRESS \
  --broadcast
```

#### RPC Providers

- Infura — https://infura.io
- Alchemy — https://alchemy.com
- Local — http://localhost:8545 *(Hardhat/Anvil/Ganache)*

#### Example

```bash
forge script script/DeployFactory.s.sol:DeployFactory \
  --rpc-url https://sepolia.infura.io/v3/your-id \
  --private-key 0xabc123... \
  --sig "run(address)" \
  0x742d35Cc6634C0532925a3b8Dc9F1a5C6C7B8A2A \
  --broadcast
```

> ⚠️ **Security Warning**  
> Never commit your private key or expose it publicly.

---

### 4. Create ERC20 tokens

The factory supports:

- `platformDeploy(...)` — platform-managed token deployment  
- `userDeploy(...)` — self-service token creation (fee required)  

---

## License

MIT License
