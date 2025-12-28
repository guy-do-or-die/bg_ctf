// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/ISeason2Challenge9.sol";

contract ResearchS2C9 is Script {
    function run() external {
        address target = 0x3f7aF25E3Fb83789a8f63c4f3292F96763cd3D12;
        address user = 0x830bc5551e429DDbc4E9Ac78436f8Bf13Eca8434;

        vm.startBroadcast();

        try ISeason2Challenge9(target).owner() returns (address owner) {
            console.log("Owner:", owner);
            uint256 size;
            assembly { size := extcodesize(owner) }
            console.log("Owner Code Size:", size);
            
            if (owner == user) {
                console.log("User IS the owner! We can add minters.");
            } else {
                console.log("User is NOT the owner.");
            }
            
            if (owner == target) {
                 console.log("Owner is the contract itself!");
            }
            
            bool ownerMinter = ISeason2Challenge9(target).isMinter(owner);
            console.log("Is Owner Minter?", ownerMinter);
            
            bool targetMinter = ISeason2Challenge9(target).isMinter(target);
            console.log("Is Target(Contract) Minter?", targetMinter);
            
            // Check derived address 0xFABB0ac9d68B0B445fB7357272Ff202C5651694a
            address derived = 0xFABB0ac9d68B0B445fB7357272Ff202C5651694a;
            bool derivedMinter = ISeason2Challenge9(target).isMinter(derived);
            console.log("Is Derived Minter (0xFABB...)?", derivedMinter);

        } catch {
            console.log("Failed to fetch owner.");
        }

        try ISeason2Challenge9(target).isMinter(user) returns (bool isMinter) {
            console.log("Is User Minter?", isMinter);
        } catch {
             console.log("Failed to check if user is minter.");
        }
        
        // Check address(0)
        try ISeason2Challenge9(target).isMinter(address(0)) returns (bool isMinter) {
            console.log("Is address(0) Minter?", isMinter);
        } catch {
             console.log("Failed to check if address(0) is minter.");
        }
        
        // Check storage slot 2 (minters mapping) for user
        // Mapping key is keccak256(key . slot)
        bytes32 userKey = keccak256(abi.encode(user, uint256(2)));
        bytes32 userVal = vm.load(target, userKey);
        console.logBytes32(userVal);
        
        // Check storage slot 2 for address(0)
        bytes32 zeroKey = keccak256(abi.encode(address(0), uint256(2)));
        bytes32 zeroVal = vm.load(target, zeroKey);
        console.log("Address(0) Storage Value:");
        console.logBytes32(zeroVal);

        vm.stopBroadcast();
    }
}
