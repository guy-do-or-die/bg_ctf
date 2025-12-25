// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IChallenge7 {
    function claimOwnership() external;
    function mintFlag() external;
    function owner() external view returns (address);
}
