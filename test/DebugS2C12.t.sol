// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

contract DebugS2C12 is Test {
    address goldAddress = 0x84710c7E262B09fa3aAF97F2741E7CE6Fb11A54b;
    IERC20 gold = IERC20(goldAddress);
    address target = 0xac22A9b80bf87Cdb1f95efEb3F2A504f5039BE9d; // Challenge

    function setUp() public {
        vm.createSelectFork("https://mainnet.optimism.io");
    }

    function testApprove() public {
        address me = address(this);
        uint256 amount = 1 ether;
        
        console.log("Approving...");
        gold.approve(target, amount);
        
        uint256 allo = gold.allowance(me, target);
        console.log("Allowance:", allo);
        
        require(allo == amount, "Allowance failed!");
    }
}
