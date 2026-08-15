// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IWorldID {
    /// @notice Verifies a World ID proof on-chain.
    /// @param root The Merkle root of the identity group.
    /// @param groupId The identity group to verify against (typically 1 for Orb).
    /// @param signalHash The keccak256 hash of the signal.
    /// @param nullifierHash The nullifier hash to prevent sybil attacks.
    /// @param externalNullifierHash The external nullifier hash.
    /// @param proof The ZK proof.
    function verifyProof(
        uint256 root,
        uint256 groupId,
        uint256 signalHash,
        uint256 nullifierHash,
        uint256 externalNullifierHash,
        uint256[8] calldata proof
    ) external view;
}
