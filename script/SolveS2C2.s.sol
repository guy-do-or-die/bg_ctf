// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/ISeason2Challenge2.sol";

contract SolveS2C2 is Script {
    function run() external {
        address target = 0xFB4b32A60b975546Ed2959638B94259853F6a4b5;
        
        vm.startBroadcast();

        // compute key
        // key = keccak256(abi.encodePacked(msg.sender, address(this)))
        // In the challenge contract: key = keccak256(abi.encodePacked(msg.sender, address(this)))
        // So we need to match that.
        // My msg.sender is me. address(this) in the challenge is the challenge contract address.
        
        bytes32 key = keccak256(abi.encodePacked(msg.sender, target));
        
        console.log("My Address: ", msg.sender);
        console.log("Target:     ", target);
        console.log("Computed Key: ");
        console.logBytes32(key);

        ISeason2Challenge2(target).mintFlag(key);

        vm.stopBroadcast();
    }
}
