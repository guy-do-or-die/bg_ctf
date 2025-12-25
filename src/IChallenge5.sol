// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IChallenge5 {
    function claimPoints() external;
    function mintFlag() external;
    function points(address) external view returns (uint256);
}
