// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "../src/Solver6.sol";

contract Solve6Script is Script {
    function run() external {
        vm.startBroadcast();
        address target = 0x75961D2da1DEeBaEC24cD0E180187E6D55F55840;
        Solver6 solver = new Solver6();
        solver.solve{gas: 500000}(target, 197100);
        vm.stopBroadcast();
    }
}
