// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./ISeason2Challenge4.sol";

contract SolverS2C4 {
    function solve(address target) external payable {
        ISeason2Challenge4(target).mintFlag();
    }

    receive() external payable {
        // If we receive a call with 0 value (the callback), send 1 gwei back
        if (msg.value == 0) {
            (bool ok,) = msg.sender.call{value: 1 gwei}("");
            require(ok, "failed to pay back");
        }
    }
}
