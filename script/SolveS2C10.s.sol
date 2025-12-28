// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/SolverS2C10.sol";

contract SolveS2C10 is Script {
    function run() external {
        address target = 0x7752f239787bdD6cEf421f4954cb647869fE08B9;
        address deployerEOA = 0x830bc5551e429DDbc4E9Ac78436f8Bf13Eca8434;
        
        vm.startBroadcast();
        // 1. Deploy a custom Factory.
        // The Factory will perform CREATE2. The Factory's address is deterministic based on EOA nonce.
        Deployer factory = new Deployer();
        console.log("Factory Address:", address(factory));
        
        // 2. Mine salt for the Factory to use.
        // Address = keccak256(0xff ++ factory ++ salt ++ hash(bytecode))
        bytes memory bytecode = abi.encodePacked(type(SolverS2C10).creationCode, abi.encode(target));
        bytes32 bytecodeHash = keccak256(bytecode);
        
        uint256 salt;
        address predicted;
        bool found;
        
        console.log("Mining salt for pattern 0x7.......4 using Factory...");
        
        for (uint256 i = 0; i < 65535; i++) {
            predicted = vm.computeCreate2Address(
                bytes32(i),
                bytecodeHash,
                address(factory) // Deployer is the FACTORY now
            );
            
            bool firstMatch = (uint8(bytes20(predicted)[0]) >> 4) == 0x7;
            bool lastMatch = (uint8(bytes20(predicted)[19]) & 0x0F) == 0x4;
            
            if (firstMatch && lastMatch) {
                salt = i;
                found = true;
                console.log("FOUND Salt:", salt);
                console.log("Predicted:", predicted);
                break;
            }
        }
        
        require(found, "Failed to find salt");

        // 3. Call factory to deploy
        factory.deploy(bytes32(salt), bytecode);
        
        vm.stopBroadcast();
    }
}

contract Deployer {
    function deploy(bytes32 salt, bytes memory bytecode) public {
        address addr;
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Deployment failed");
    }
}
