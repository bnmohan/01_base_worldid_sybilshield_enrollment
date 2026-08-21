#!/bin/bash
echo "🚀 Setting up standalone environment for World ID SybilShield Gateway..."

# 1. Update foundry.toml for local libraries
if [ -f contracts/foundry.toml ]; then
  echo "🔧 Configuring contracts/foundry.toml to use local libraries..."
  sed -i.bak "s|libs = \['../../lib'\]|libs = \['lib'\]|g" contracts/foundry.toml 2>/dev/null || \
  sed -i "" "s|libs = \['../../lib'\]|libs = \['lib'\]|g" contracts/foundry.toml
  rm -f contracts/foundry.toml.bak
fi

# 2. Create .env if it does not exist
if [ -f contracts/.env.example ] && [ ! -f contracts/.env ]; then
  echo "📝 Creating contracts/.env from template..."
  cp contracts/.env.example contracts/.env
fi

# 3. Install forge-std dependency locally
if [ -d contracts ]; then
  echo "📦 Installing Forge dependencies locally..."
  cd contracts
  # Initialize forge dependencies only if not already installed
  if [ ! -d "lib/forge-std" ]; then
    forge install foundry-rs/forge-std --no-git
  fi
  
  echo "🔨 Compiling smart contracts..."
  forge build

  # 4. Check if Anvil is running on port 8545 and auto-deploy
  if nc -z 127.0.0.1 8545 2>/dev/null || curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://127.0.0.1:8545 >/dev/null 2>&1; then
    echo "⚡ Detected active Anvil node on http://127.0.0.1:8545. Deploying local contracts..."
    DEPLOY_OUT=$(forge script script/DeployAnvil.s.sol:DeployAnvilScript --rpc-url http://127.0.0.1:8545 --broadcast)
    ANVIL_ADDR=$(echo "$DEPLOY_OUT" | grep "HumanVerifier deployed to:" | awk '{print $NF}' | tail -n 1)
    
    if [ -n "$ANVIL_ADDR" ]; then
      echo "🎯 HumanVerifier deployed on Anvil: $ANVIL_ADDR"
      cd ..
      # Update Anvil CONTRACT_ADDRESS in frontend/config.js
      sed -i.bak "s|CONTRACT_ADDRESS: \".*\"|CONTRACT_ADDRESS: \"$ANVIL_ADDR\"|g" frontend/config.js 2>/dev/null || \
      sed -i "" "s|CONTRACT_ADDRESS: \".*\"|CONTRACT_ADDRESS: \"$ANVIL_ADDR\"|g" frontend/config.js
      rm -f frontend/config.js.bak
      echo "✅ Updated frontend/config.js with Anvil contract address: $ANVIL_ADDR"
      cd contracts
    fi
  else
    echo "ℹ️  Anvil is not running yet. Run 'anvil --fork-url https://sepolia.base.org --chain-id 31337' and rerun setup to deploy automatically."
  fi

  cd ..
fi

echo "✅ Setup complete! Serve the frontend directory to test the feature:"
echo "   cd frontend && python3 -m http.server 8001"
