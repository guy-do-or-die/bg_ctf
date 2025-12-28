// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./ISeason2Challenge3.sol";

contract SolverS2C3 {
    function accessKey() external pure returns (string memory) {
        return "LET_ME_IN";
    }

    function solve(address target) external {
        ISeason2Challenge3(target).mintFlag();
    }
}
