// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/console.sol";
import "./ISeason2Challenge9.sol";

contract SolverS2C9 {
    constructor(address target, address minterAddress, bytes memory signature) {
        console.log("Solver execution address:", address(this));
        // Call the challenge
        // We act as the 'sender' here, so the signature must be valid for address(this).
        // Use low-level call to ensure correct selector
        (bool success, bytes memory ret) = target.call(abi.encodeWithSelector(0x23cfec7e, minterAddress, signature));
        require(success, string(abi.encodePacked("Call failed: ", ret)));
    }
}
