// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/ISeason2Challenge9.sol";

contract DebugS2C9 is Script {
    function run() external {
        address target = 0x3f7aF25E3Fb83789a8f63c4f3292F96763cd3D12;
        string memory mnemonic = "test test test test test test test test test test test junk";
        uint32 index = 12;
        
        uint256 minterPrivateKey = vm.deriveKey(mnemonic, index);
        address minterAddress = vm.addr(minterPrivateKey);
        console.log("Derived Minter:", minterAddress);
        console.log("Msg Sender:", msg.sender);
        
        vm.startBroadcast();
        
        // Attempt 1: abi.encode (Standard)
        tryAttempt(target, minterPrivateKey, minterAddress, true, 0); 
        
        // Attempt 2: abi.encodePacked (Packed)
        tryAttempt(target, minterPrivateKey, minterAddress, false, 0);

        // Attempt 3: abi.encode (Standard) with v-27 (0/1)
        tryAttempt(target, minterPrivateKey, minterAddress, true, 27);
        
        // Attempt 4: abi.encodePacked (Packed) with v-27 (0/1)
        tryAttempt(target, minterPrivateKey, minterAddress, false, 27);
        
        vm.stopBroadcast();
    }
    
    function tryAttempt(address target, uint256 pk, address minter, bool standard, uint8 vShift) internal {
        bytes32 hash;
        if (standard) {
            hash = keccak256(abi.encode("BG CTF Challenge 9", msg.sender));
            console.log("Trying abi.encode...");
        } else {
            hash = keccak256(abi.encodePacked("BG CTF Challenge 9", msg.sender));
            console.log("Trying abi.encodePacked...");
        }
        
        bytes32 ethHash = ECDSA.toEthSignedMessageHash(hash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, ethHash);
        
        if (vShift > 0 && v >= vShift) {
            v -= vShift;
        }
        
        bytes memory signature = abi.encodePacked(r, s, v);
        
        try ISeason2Challenge9(target).unknown23cfec7e(minter, signature) {
            console.log("SUCCESS!");
        } catch Error(string memory reason) {
            console.log("Failed:", reason);
        } catch (bytes memory) {
            console.log("Failed (Unknown)");
        }
    }
}

library ECDSA {
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
    }
}
