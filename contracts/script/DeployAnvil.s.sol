// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { HumanVerifier } from "../src/HumanVerifier.sol";
import { MockWorldID } from "../src/mocks/MockWorldID.sol";
import { IWorldID } from "../src/interfaces/IWorldID.sol";

contract DeployAnvilScript is Script {
    function run() external returns (HumanVerifier) {
        // Standard Anvil default account #0 private key
        uint256 deployerPrivateKey = vm.envOr(
            "ANVIL_PRIVATE_KEY", 
            uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );
        
        string memory appId = vm.envOr("APP_ID", string("app_90ae7b9bb264a71be4f6744af3e39649"));
        string memory actionId = vm.envOr("ACTION_ID", string("login"));
        
        uint256 appIdHash = uint256(keccak256(abi.encodePacked(appId))) >> 8;
        uint256 externalNullifier = uint256(keccak256(abi.encodePacked(appIdHash, actionId))) >> 8;
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 1. Deploy MockWorldID on Anvil
        MockWorldID mockWorldId = new MockWorldID();
        console.log("MockWorldID deployed to:", address(mockWorldId));
        
        // 2. Deploy HumanVerifier pointing to MockWorldID
        HumanVerifier verifier = new HumanVerifier(
            IWorldID(address(mockWorldId)),
            externalNullifier
        );
        
        vm.stopBroadcast();
        
        console.log("HumanVerifier deployed to:", address(verifier));
        return verifier;
    }
}
