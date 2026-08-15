// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IWorldID } from "../interfaces/IWorldID.sol";

contract MockWorldID is IWorldID {
    /// @notice Mock implementation of World ID verifier.
    /// @dev If proof[0] == 999, it simulates verification failure by reverting.
    function verifyProof(
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256[8] calldata proof
    ) external pure override {
        // If proof[0] == 999, revert to simulate validation failure
        if (proof[0] == 999) {
            revert("MockWorldID: Invalid proof");
        }
        
        // Otherwise, do nothing (which is success)
    }
}
