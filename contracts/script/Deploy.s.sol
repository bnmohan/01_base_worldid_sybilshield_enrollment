// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { HumanVerifier } from "../src/HumanVerifier.sol";
import { IWorldID } from "../src/interfaces/IWorldID.sol";

contract DeployScript is Script {
    function run() external returns (HumanVerifier) {
        // Load private key from environment variable, default to Anvil private key
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));
        
        // Base Sepolia World ID Router address
        address worldIdRouter = vm.envOr("WORLD_ID_ROUTER", address(0x42FF98C4E85212a5D31358ACbFe76a621b50fC02));
        
        // World ID Parameters matching the frontend
        string memory appId = "app_staging_vibepoll";
        string memory actionId = "login";
        
        // Calculate externalNullifier using World ID hashing rules:
        // uint256(keccak256(abi.encodePacked(uint256(keccak256(abi.encodePacked(appId))) >> 8, actionId))) >> 8
        uint256 appIdHash = uint256(keccak256(abi.encodePacked(appId))) >> 8;
        uint256 externalNullifier = uint256(keccak256(abi.encodePacked(appIdHash, actionId))) >> 8;
        
        console.log("Using World ID Router at:", worldIdRouter);
        console.log("Calculated External Nullifier:", externalNullifier);
        
        vm.startBroadcast(deployerPrivateKey);
        
        HumanVerifier verifier = new HumanVerifier(
            IWorldID(worldIdRouter),
            externalNullifier
        );
        
        vm.stopBroadcast();
        
        console.log("HumanVerifier deployed to:", address(verifier));
        return verifier;
    }
}
