// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";

interface INFTFlags {
    function ownerOf(uint256 tokenId) external view returns (address);
    function tokenIdToChallengeId(uint256 tokenId) external view returns (uint256);
}

contract CheckOwner is Script {
    function run() external view {
        address nftAddress = 0xc1Ebd7a78FE7c075035c516B916A7FB3f33c26cE;
        INFTFlags nft = INFTFlags(nftAddress);
        address me = 0x830bc5551e429DDbc4E9Ac78436f8Bf13Eca8434;

        // Scan a reasonable range around known recent IDs (1560-1600)
        for (uint256 id = 1550; id < 1650; id++) {
            try nft.ownerOf(id) returns (address owner) {
                if (owner == me) {
                    uint256 challengeId = nft.tokenIdToChallengeId(id);
                    console.log("Found Token ID:", id, "Challenge ID:", challengeId);
                }
            } catch {
                // Token might not exist or burned
            }
        }
    }
}
