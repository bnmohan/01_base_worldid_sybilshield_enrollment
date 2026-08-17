// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { HumanVerifier } from "../src/HumanVerifier.sol";
import { IWorldID } from "../src/interfaces/IWorldID.sol";

contract DeployScript is Script {
    function run() external returns (HumanVerifier) {
        // Exception handling: check if PRIVATE_KEY is defined in the environment
        string memory privateKeyString = vm.envOr("PRIVATE_KEY", string(""));
        if (bytes(privateKeyString).length == 0) {
            revert("Deployment Error: PRIVATE_KEY environment variable is not defined or empty in your shell environment.");
        }
        
        // Normalize the hex key by ensuring it has the "0x" prefix
        bytes memory keyBytes = bytes(privateKeyString);
        string memory normalizedKey;
        if (keyBytes.length >= 2 && keyBytes[0] == "0" && keyBytes[1] == "x") {
            normalizedKey = privateKeyString;
        } else {
            normalizedKey = string.concat("0x", privateKeyString);
        }
        
        uint256 deployerPrivateKey = uint256(vm.parseBytes32(normalizedKey));
        
        // Base Sepolia World ID Router address
        address worldIdRouter = vm.envOr("WORLD_ID_ROUTER", address(0x42FF98C4E85212a5D31358ACbFe76a621b50fC02));
        
        // World ID Parameters matching the frontend, loaded from env
        string memory appId = vm.envString("APP_ID");
        string memory actionId = vm.envString("ACTION_ID");
        
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
