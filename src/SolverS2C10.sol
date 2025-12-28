// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./ISeason2Challenge10.sol";
import "forge-std/console.sol";

contract SolverS2C10 {
    constructor(address target) {
        console.log("Solver deployed at:", address(this));
        ISeason2Challenge10(target).mintFlag();
    }
}
