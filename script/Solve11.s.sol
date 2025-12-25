// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "../src/Solver11.sol";

contract Solve11Script is Script {
    function run() external {
        address target = 0x67392ea0A56075239988B8E1E96663DAC167eF54;
        
        // My tx.origin: 0x830bc5551e429DDbc4E9Ac78436f8Bf13Eca8434
        // Last byte: 0x34 = 0011 0100
        // Mask: 0x15 = 0001 0101
        // Target: 0x34 & 0x15 = 0x14 (0001 0100)
        
        uint256 salt;
        bool found = false;
        
        // This is the create2 deployer address used by forge script by default (if using default sender)
        // Actually, if we use `new Solver11{salt: salt}(...)`, the deployer is this script contract.
        // But `this` address is determined by the deployment of the script.
        // It's safer/easier to use the IMMUTABLE_CREATE2_FACTORY if we want deterministic addresses,
        // OR we can just simulate the address in the loop since we are deploying FROM this script.
        
        // Note: When running `forge script`, the script contract is deployed at a somewhat logical address, 
        // but we can also just try to find a salt that works when deployed from THIS script contract address.
        
        // Let's find the address of THIS script contract first? 
        // Actually, we can just run the loop in broadcast. 
        // But to save gas we should find it locally.
        // The address of `new Solver11` will depends on `address(this)`.
        
        // Use the deterministic deployer proxy address used by foundry
        address deployer = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
        
        bytes memory creationCode = abi.encodePacked(
            type(Solver11).creationCode,
            abi.encode(target)
        );
        
        bytes32 initCodeHash = keccak256(creationCode);
        
        for (uint256 i = 0; i < 20000; i++) {
            bytes32 _salt = bytes32(i);
            address computed = computeCreate2Address(_salt, initCodeHash, deployer);
            
            uint8 lastByte = uint8(uint160(computed));
            if ((lastByte & 0x15) == 0x14) {
                console.log("Found salt:", i);
                console.log("Address:", computed);
                
                vm.startBroadcast();
                new Solver11{salt: _salt}(target);
                vm.stopBroadcast();
                
                found = true;
                break;
            }
        }
        
        
        require(found, "Could not find salt");
    }
}
