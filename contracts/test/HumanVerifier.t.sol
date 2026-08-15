// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Test } from "forge-std/Test.sol";
import { HumanVerifier } from "../src/HumanVerifier.sol";
import { MockWorldID } from "../src/mocks/MockWorldID.sol";

contract HumanVerifierTest is Test {
    HumanVerifier public verifier;
    MockWorldID public mockWorldID;
    
    address public user = address(0x1);
    uint256 public externalNullifier = 123456;
    uint256[8] public mockProof;

    function setUp() public {
        mockWorldID = new MockWorldID();
        verifier = new HumanVerifier(mockWorldID, externalNullifier);
    }

    function test_RegisterHuman_Success() public {
        vm.prank(user);
        
        // Setup parameters
        uint256 root = 111;
        uint256 nullifierHash = 222;

        verifier.registerHuman(root, nullifierHash, mockProof);

        assertTrue(verifier.isHuman(user));
        assertTrue(verifier.nullifierHashes(nullifierHash));
    }

    function test_RegisterHuman_RevertIfDoubleClaim() public {
        vm.startPrank(user);
        uint256 root = 111;
        uint256 nullifierHash = 222;

        verifier.registerHuman(root, nullifierHash, mockProof);
        
        // Try to register again (same user, same nullifier)
        vm.expectRevert("Address already registered");
        verifier.registerHuman(root, nullifierHash, mockProof);
        vm.stopPrank();
    }

    function test_RegisterHuman_RevertIfDoubleClaimDifferentAddress() public {
        // First user registers
        vm.prank(user);
        verifier.registerHuman(111, 222, mockProof);

        // Second user tries to register with same nullifier (different wallet)
        address user2 = address(0x2);
        vm.prank(user2);
        vm.expectRevert("Identity already registered");
        verifier.registerHuman(111, 222, mockProof);
    }

    function test_RegisterHuman_RevertIfInvalidProof() public {
        vm.prank(user);
        
        // In our MockWorldID, if proof[0] == 999, it reverts
        uint256[8] memory invalidProof;
        invalidProof[0] = 999;

        vm.expectRevert("MockWorldID: Invalid proof");
        verifier.registerHuman(111, 222, invalidProof);
    }
}
