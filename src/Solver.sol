// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./IChallenge2.sol";

contract Solver {
    constructor(address _target) {
        IChallenge2(_target).justCallMe();
    }
}
