// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/SolverS2C3.sol";

contract SolveS2C3 is Script {
    function run() external {
        address target = 0x2736fD9B1a87cb84f9e3278623AC117f11cD4655;
        
        vm.startBroadcast();

        SolverS2C3 solver = new SolverS2C3();
        console.log("Solver deployed at:", address(solver));
        
        solver.solve(target);
        
        vm.stopBroadcast();
    }
}
