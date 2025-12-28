// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./ISeason2Challenge8.sol";

contract SolverS2C8 {
    function solve(address target, bytes32 password) external payable {
        // Must send 2 wei to mintFlag
        ISeason2Challenge8(target).mintFlag{value: 2}(password);
    }

    receive() external payable {
        // lock3: require(payable(msg.sender).send(1) == false)
        // challenge sends 1 wei -> we must fail
        if (msg.value == 1) {
            revert("lock3: reject 1 wei");
        }
        
        // lock4: require(payable(msg.sender).send(2) == true)
        // challenge sends 2 wei -> we must accept (default)
        
        // Also accept funding (any other amount)
    }
}
