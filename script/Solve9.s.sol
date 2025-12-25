// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "../src/IChallenge9.sol";

contract Solve9Script is Script {
    function run() external {
        address target = 0x1Fd913F2250ae5A4d9F8881ADf3153C6e5E2cBb1;

        // Read private state from storage
        // Slot 0: nftContract (address)
        // Slot 1: password (bytes32)
        // Slot 2: count (uint256)

        bytes32 password = vm.load(target, bytes32(uint256(1)));
        bytes32 countBytes = vm.load(target, bytes32(uint256(2)));
        uint256 count = uint256(countBytes);

        // Calculate expected value
        // logic: bytes32 mask = ~(bytes32(uint256(0xFF) << ((31 - (count % 32)) * 8)));
        // bytes32 newPassword = password & mask;

        bytes32 mask = ~(bytes32(uint256(0xFF) << ((31 - (count % 32)) * 8)));
        bytes32 solution = password & mask;

        vm.startBroadcast();
        IChallenge9(target).mintFlag(solution);
        vm.stopBroadcast();
    }
}
