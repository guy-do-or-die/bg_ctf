// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "../src/INFTFlags.sol";

contract Solve10Script is Script {
    function run() external {
        address nftAddress = 0xc1Ebd7a78FE7c075035c516B916A7FB3f33c26cE;
        INFTFlags nft = INFTFlags(nftAddress);
        
        // Sender from Challenge 4 logs: 0x830bc5551e429DDbc4E9Ac78436f8Bf13Eca8434
        address me = 0x830bc5551e429DDbc4E9Ac78436f8Bf13Eca8434;

        uint256 maxId = nft.tokenIdCounter();
        console.log("Total tokens:", maxId);
        
        uint256 id1 = 0;
        uint256 id9 = 0;

        // Iterate backwards to find latest tokens
        // Check last 2000 tokens or until 0
        uint256 start = maxId;
        uint256 stop = maxId > 2000 ? maxId - 2000 : 0;

        for(uint256 i = start; i > stop; i--) {
            try nft.ownerOf(i) returns (address owner) {
                if (owner == me) {
                    uint256 challengeId = nft.tokenIdToChallengeId(i);
                    console.log("Found token", i, "for Challenge", challengeId);
                    if (challengeId == 1 && id1 == 0) {
                        id1 = i;
                    } else if (challengeId == 9 && id9 == 0) {
                        id9 = i;
                    }
                }
            } catch {}
            
            if (id1 != 0 && id9 != 0) break;
        }

        require(id1 != 0, "Flag 1 not found");
        require(id9 != 0, "Flag 9 not found");

        console.log("Using Flag 1 ID:", id1);
        console.log("Using Flag 9 ID:", id9);

        vm.startBroadcast();
        nft.safeTransferFrom(me, nftAddress, id1, abi.encode(id9));
        vm.stopBroadcast();
    }
}
