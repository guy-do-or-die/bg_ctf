// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";

interface INFTFlags {
    function balanceOf(address owner) external view returns (uint256);
}

contract CheckSolverBalance is Script {
    function run() external view {
        address nftAddress = 0xc1Ebd7a78FE7c075035c516B916A7FB3f33c26cE;
        address solverAddr = 0xc49e98cc2aeA0A54164fC1e16991A2bfAaB0c626;
        
        INFTFlags nft = INFTFlags(nftAddress);
        uint256 bal = nft.balanceOf(solverAddr);
        console.log("Solver Balance:", bal);
    }
}
