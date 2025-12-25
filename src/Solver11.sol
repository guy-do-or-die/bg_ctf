// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IChallenge11 {
    function mintFlag() external;
}

contract Solver11 {
    constructor(address target) {
        IChallenge11(target).mintFlag();
    }
}
