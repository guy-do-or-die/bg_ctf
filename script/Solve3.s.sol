// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "../src/Solver3.sol";

contract Solve3Script is Script {
    function run() external {
        vm.startBroadcast();
        address target = 0x03bF70f50fcF9420f27e31B47805bbd8f2f52571;
        new Solver3(target);
        vm.stopBroadcast();
    }
}
