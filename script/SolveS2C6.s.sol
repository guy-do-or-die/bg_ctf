// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/SolverS2C6.sol";

contract SolveS2C6 is Script {
    function run() external {
        address target = 0xd523DfA613b8c5fA352ED02D6cB2fE1ed83901CE;
        
        vm.startBroadcast();

        SolverS2C6 solver = new SolverS2C6();
        console.log("Solver deployed at:", address(solver));
        
        solver.solve(target);
        
        vm.stopBroadcast();
    }
}
