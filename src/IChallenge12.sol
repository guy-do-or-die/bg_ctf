// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IChallenge12 {
    function preMintFlag() external;
    function mintFlag(bytes memory rlpBytes) external;
    function blockNumber(address) external view returns (uint256);
}
