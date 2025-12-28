// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface ISeason2Challenge9 {
    function owner() external view returns (address);
    function isMinter(address _account) external view returns (bool);
    function addMinter(address _minter) external;
    // The solve function: 0x23cfec7e
    // unknown23cfec7e(uint128 _param1, array _param2)
    // _param1 seems to be address (minter), _param2 is bytes (signature)
    // Decompiler says: require not Mask(96, 160, _param1) -> address check
    function unknown23cfec7e(address minter, bytes memory signature) external;
}
