# 🛡️ World ID SybilShield Enrollment Gateway

[![Base Sepolia](https://img.shields.io/badge/Network-Base_Sepolia-blue?logo=ethereum)](#)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.24-lightgrey?logo=solidity)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Framework-Foundry-orange)](https://getfoundry.sh/)
[![World ID](https://img.shields.io/badge/Privacy-World_ID_ZK_Proofs-green)](https://worldcoin.org/world-id)

> **Generic, modular, and privacy-preserving SybilShield enrollment framework for Web3 dapps on Base using Worldcoin World ID Zero-Knowledge (ZK) proofs.**

---

## 🌟 Executive Overview & Web3 Paradigm Aim

In Web3 dapps, DAOs, airdrops, quadratic funding, and grant distribution programs, applications face two major challenges:
1. **Sybil Attacks & Bot Farms**: Automated bots create thousands of fake wallets to claim rewards and manipulate voting.
2. **Privacy Invasion**: Traditional KYC forces users to upload plain-text ID cards to centralized databases, creating honeypots for identity theft.

### The Plug-and-Play Solution: Generic ZK SybilShield
This repository provides a **reusable, modular SybilShield enrollment gateway** powered by **World ID**. Any Web3 application (e.g. Dadami, DAOs, Grant Hubs, Airdrop platforms) can import `HumanVerifier.sol` to allow real humans to verify their unique humanity using Orb-verified zero-knowledge credentials **without revealing any personal identity or real-world credentials on-chain**.

---

## 🔬 Key Web3 Technical Concepts & Architecture

### 1. Off-Chain Prover / On-Chain Verifier Paradigm
- **Off-Chain Prover (World App / IDKit)**: The user scans their Orb-verified identity. The World App generates a **ZK-SNARK proof** (Semaphore protocol) locally. The user's actual identity credentials **never leave their device**.
- **On-Chain Verifier ([HumanVerifier.sol](file:///Users/mohanbn/Projects/Antigravity/01_base_worldid_sybilshield_enrollment/contracts/src/HumanVerifier.sol))**: Receives the mathematical ZK proof output payload on Base Sepolia and verifies it against the current World ID Merkle root on-chain.

### 2. Nullifier Cryptography (Sybil Resistance)
- A **Nullifier Hash** is a deterministic, blind hash generated from the user's credential and the application's unique Action ID: `nullifierHash = Poseidon(secret, actionId)`.
- The smart contract records `nullifierHashes[nullifierHash] = true`. If a user attempts to register a second wallet using the same World ID credential for the same action, the contract rejects the transaction with `"Identity already registered"`.

### 3. Scalable Layer-2 Execution on Base
- Operating on **Base L2** ensures lightning-fast transaction settlement and sub-cent gas costs for human verification.

---

## 📍 Live On-Chain Deployments (Base Sepolia Testnet)

| Contract | Network | Deployed Address | Block Explorer |
| :--- | :--- | :--- | :--- |
| **`HumanVerifier`** | **Base Sepolia** | *TBD (Pending Deployment)* | [View on BaseScan](#) |

- **Deployment Tx Hash**: *TBD (Pending Deployment)*

---

## 🛠️ Project Architecture & Data Schema

```
01_base_worldid_sybilshield_enrollment/
├── README.md                               # Project documentation
├── contracts/
│   ├── src/
│   │   ├── interfaces/
│   │   │   └── IWorldID.sol                # World ID Router interface
│   │   ├── mocks/
│   │   │   └── MockWorldID.sol             # Mock World ID verifier for testing
│   │   └── HumanVerifier.sol               # Core enrollment logic
│   ├── test/
│   │   └── HumanVerifier.t.sol             # Automated Forge unit test suite
│   ├── script/
│   │   └── Deploy.s.sol                    # Solidity deployment script
│   ├── foundry.toml                        # Forge compiler & remappings config
│   └── .env                                # Protected deployment key storage (.gitignore)
└── frontend/
    └── index.html                          # Glassmorphic Dapp gateway UI
```

### On-Chain Data Schema (`HumanVerifier.sol`)
* `isHuman[address => bool]`: Maps wallet address to verified human status.
* `nullifierHashes[uint256 => bool]`: Prevents reuse of the same World ID identity across multiple wallets for the same Action ID.
* `worldId`: Immutable reference to the World ID Router contract on Base Sepolia.
* `groupId`: Target Semaphore group ID (Default is `1` for Orb-verified users).
* `externalNullifier`: Unique action identifier hash calculated from `appId` and `actionId`.

---

## 🧰 Technology Stack

- **Smart Contracts**: Solidity `^0.8.24`
- **Development & Testing**: Foundry (`forge`, `cast`)
- **Zero-Knowledge Protocol**: Worldcoin World ID (Semaphore ZK-Proofs)
- **Blockchain Network**: Base Sepolia Testnet (Chain ID `84532`)
- **Frontend Dapp**: Vanilla HTML5 / Modern CSS3 (Glassmorphism), Ethers.js `v6`, World ID IDKit JS SDK

---

## 🚀 Quickstart & Local Setup

To easily set up this repository in standalone mode (configure environment files, install local dependencies, and compile contracts in one click), run:
```bash
chmod +x setup.sh
./setup.sh
```


### 1. Smart Contract Compilation & Unit Tests
```bash
cd contracts

# Compile Solidity contracts
forge build

# Run automated unit tests
forge test -vv
```

### 2. Deploying to Base Sepolia
```bash
cd contracts

# Copy your environment variables or create .env file:
# PRIVATE_KEY=your_private_key_here
# BASE_SEPOLIA_RPC_URL=your_alchemy_or_infura_url_here

# Deploy the contract using the Foundry script
forge script script/Deploy.s.sol:DeployScript --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast --verify -vvvv
```

## 🌐 Multi-Network Testing Guide

Start the local web server:
```bash
cd frontend
python3 -m http.server 8001
```

---

### Option A: Test Live on Base Sepolia Testnet

1. Open **[http://localhost:8001/?network=sepolia](http://localhost:8001/?network=sepolia)** in Chrome with MetaMask.
2. In MetaMask, connect to **Base Sepolia** (`Chain ID: 84532`).
3. Click **Connect MetaMask Wallet** $\rightarrow$ Click **Verify with World ID** to trigger the IDKit modal with your World App.

---

### Option B: Test Locally on Anvil Fork (Fast & Free)

1. **Launch the local Anvil fork**:
   ```bash
   anvil --fork-url https://sepolia.base.org --chain-id 31337
   ```
2. Open **[http://localhost:8001/?network=anvil](http://localhost:8001/?network=anvil)** in Chrome with MetaMask.
3. In MetaMask, select **Localhost 8545** (`Chain ID: 31337`).
4. Connect using pre-funded test accounts to test verification against the preloaded contract state!

---

## 📜 License
MIT License. Built with ❤️ for the Base Ecosystem.

