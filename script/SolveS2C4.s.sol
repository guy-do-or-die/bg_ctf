// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/SolverS2C4.sol";

contract SolveS2C4 is Script {
    function run() external {
        address target = 0x49918e16349416Ae13827758Bc8F8267e25D7B1c;
        
        vm.startBroadcast();

        SolverS2C4 solver = new SolverS2C4();
        console.log("Solver deployed at:", address(solver));
        
        // Fund the solver and execute
        // We need to send enough ETH to the solver so it can pay back 1 gwei
        solver.solve{value: 0.0001 ether}(target);
        
        vm.stopBroadcast();
    }
}
