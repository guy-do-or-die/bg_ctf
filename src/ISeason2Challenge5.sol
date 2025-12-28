// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface ISeason2Challenge5 {
    function mintFlag(uint256[] memory data1, uint256[] memory data2) external;
    function nftContract() external view returns (address);
}
