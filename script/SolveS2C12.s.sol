// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/SolverS2C12.sol";
import "../src/ISeason2Challenge12.sol";

interface IS2NFTFlags {
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function balanceOf(address owner) external view returns (uint256);
}

contract SolveS2C12 is Script {
    function run() external {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // address me = vm.addr(deployerPrivateKey);
        address me = msg.sender;

        vm.startBroadcast();

        address target = 0xac22A9b80bf87Cdb1f95efEb3F2A504f5039BE9d;
        ISeason2Challenge12 challenge = ISeason2Challenge12(target);
        IS2NFTFlags nft = IS2NFTFlags(challenge.nftContract());
        ISeason2Challenge12GoldToken gold = ISeason2Challenge12GoldToken(challenge.challenge12GoldToken());
        ISeason2Challenge12HeroNFT hero = ISeason2Challenge12HeroNFT(challenge.challenge12HeroNFT());
        ISeason2Challenge12Dungeon dungeon = ISeason2Challenge12Dungeon(challenge.challenge12Dungeon());

        // 1. Get Gold (if balance is low)
        // We know we own Token 7 (C2) and Token 8 (Other)
        uint256 c2TokenId = 7;
        uint256 wrapperTokenId = 8;

        if (gold.balanceOf(me) < 1000 ether) {
            console.log("Minting GoldTokens...");
            nft.safeTransferFrom(me, address(nft), wrapperTokenId, abi.encode(c2TokenId));
        }
        uint256 bal = gold.balanceOf(me);
        console.log("Gold Balance:", bal); // Should be >= 1000 ether

        // 2. Deploy Solver
        SolverS2C12 solver = new SolverS2C12(target);
        console.log("Solver deployed at:", address(solver));

        // 3. Setup Transfer Constraints
        // Need HeroNFT
        if (hero.balanceOf(me) == 0) {
            hero.mint("setup");
        }
        // Need Dungeon > HeroNFT balance (1)
        dungeon.setPosition(bytes32(uint256(2)));

        // 4. Distribute Gold
        // 1 ether to Enemy (~me)
        address enemy = address(~bytes20(me));
        if (gold.balanceOf(enemy) < 1 ether) {
            gold.transfer(enemy, 1 ether);
        }

        // Remainder to Solver (Balance - 1 ether) (We keep 1 ether? No, we keep 0?)
        // Requirement: Gold.balanceOf(tx.origin) == Gold.balanceOf(~tx.origin)
        // Enemy has 1 ether.
        // We (tx.origin) must have 1 ether.
        // So we transfer (Total - 1) to Solver.
        // Wait, if we keep 1 ether, we have 1. Enemy has 1. Condition met.
        // Solver has the rest.

        uint256 toSend = gold.balanceOf(me) - 1 ether;
        gold.transfer(address(solver), toSend);

        console.log("My Gold Balance (Final):", gold.balanceOf(me)); // Should be 1 ether
        console.log("Enemy Gold Balance:", gold.balanceOf(enemy)); // Should be 1 ether
        console.log("Solver Gold Balance:", gold.balanceOf(address(solver)));

        // 5. Execute Solver
        solver.solve();

        vm.stopBroadcast();
    }
}
