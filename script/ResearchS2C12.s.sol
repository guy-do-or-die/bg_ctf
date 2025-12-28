// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/ISeason2Challenge12.sol";

interface IS2C12GoldToken {
    function nftContract() external view returns (address);
}

contract ResearchS2C12 is Script {
    function run() external view {
        address target = 0xac22A9b80bf87Cdb1f95efEb3F2A504f5039BE9d;
        ISeason2Challenge12 challenge = ISeason2Challenge12(target);
        address nftContract = challenge.nftContract();

        console.log("Challenge:", target);
        console.log("NFT Contract:", nftContract);
        
        address goldToken = challenge.challenge12GoldToken();
        console.log("Gold Token:", goldToken);
        
        // Scan for tokens
        // We assume we own some tokens. S2C10 solver found tokens around ID 1500-1600.
        // Let's scan a range.
        
        // Interface for NFT
        IS2NFT nft = IS2NFT(nftContract);
        uint256 balance = nft.balanceOf(msg.sender);
        console.log("My NFT Balance:", balance);

        uint foundC2 = 0;
        uint foundOther = 0;

        // Naive scan (efficient enough for view script)
        // Optimization: Use `tokenOfOwnerByIndex` if Enumerable? 
        // S2NFTFlags inherits ERC721 but maybe not Enumerable? 
        // Source implies it does NOT inherit Enumerable.
        // So we must scan indices or use known IDs.
        // We solved C2, C3, C4... C11.
        // IDs are sequential.
        
        uint counter = nft.tokenIdCounter();
        console.log("Total Tokens:", counter);
        
        for (uint i = 1; i <= counter; i++) {
            try nft.ownerOf(i) returns (address owner) {
                uint cId = nft.tokenIdToChallengeId(i);
                console.log("Token:", i);
                console.log("Challenge:", cId);
                console.log("Owner:", owner);
            } catch {
                console.log("Token:", i, "Burned or Invalid");
            }
        }
    }
}

interface IS2NFT {
    function balanceOf(address) external view returns (uint);
    function ownerOf(uint) external view returns (address);
    function tokenIdToChallengeId(uint) external view returns (uint);
    function tokenIdCounter() external view returns (uint);
}
