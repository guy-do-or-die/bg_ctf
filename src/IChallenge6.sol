// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IChallenge6 {
    function mintFlag(uint256 code) external;
    function count() external view returns (uint256);
}
