// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";

interface INFTFlags {
    function balanceOf(address owner) external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenIdToChallengeId(uint256 tokenId) external view returns (uint256);
}

contract CheckTokens is Script {
    function run() external view {
        address nftAddress = 0xc1Ebd7a78FE7c075035c516B916A7FB3f33c26cE;
        INFTFlags nft = INFTFlags(nftAddress);
        address me = 0x830bc5551e429DDbc4E9Ac78436f8Bf13Eca8434;

        uint256 bal = nft.balanceOf(me);
        console.log("Balance:", bal);

        for (uint256 i = 0; i < bal; i++) {
            uint256 id = nft.tokenOfOwnerByIndex(me, i);
            uint256 challengeId = nft.tokenIdToChallengeId(id);
            console.log("Token ID:", id, "Challenge ID:", challengeId);
        }
    }
}
