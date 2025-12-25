// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IChallenge4 {
    function addMinter(address _minter) external;
    function removeMinter(address _minter) external;
    function mintFlag(address _minter, bytes memory signature) external;
    function isMinter(address) external view returns (bool);
    function owner() external view returns (address);
}
