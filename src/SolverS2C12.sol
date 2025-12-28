// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../src/ISeason2Challenge12.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract SolverS2C12 {
    using Strings for uint256;

    ISeason2Challenge12 public challenge;
    ISeason2Challenge12GoldToken public gold;
    ISeason2Challenge12HeroNFT public hero;
    ISeason2Challenge12Inventory public inventory;
    ISeason2Challenge12Quest public quest;
    ISeason2Challenge12Dungeon public dungeon;
    ISeason2Challenge12Victory public victory;

    constructor(address _challenge) {
        challenge = ISeason2Challenge12(_challenge);
        gold = ISeason2Challenge12GoldToken(challenge.challenge12GoldToken());
        hero = ISeason2Challenge12HeroNFT(challenge.challenge12HeroNFT());
        inventory = ISeason2Challenge12Inventory(challenge.challenge12Inventory());
        quest = ISeason2Challenge12Quest(challenge.challenge12Quest());
        dungeon = ISeason2Challenge12Dungeon(challenge.challenge12Dungeon());
        victory = ISeason2Challenge12Victory(challenge.challenge12Victory());
    }

    function solve() external {
        // 1. We assume we have GoldTokens (e.g. >= 1 ether)
        uint256 currentBalance = gold.balanceOf(address(this));
        console.log("Solver Gold Balance Start:", currentBalance);

        // 2. Set Victory (Winner)
        victory.free(true);

        uint256 targetInv = 0;
        uint256 targetBal = 0;
        string memory targetUri;
        bool found = false;

        bytes32 prevHash = blockhash(block.number - 1);

        // Start from 1 ether (10^18) because mintFlag pulls 1 ether via transferFrom.
        // And presumably allowance must equal inventory.
        // 1 ether is 1000000000000000000. All digits are <= 4. Valid.
        
        uint256 start = 1000000000000000000;
        
        // Iterate to find a valid inventory
        uint256 candidate = start;
        for (uint256 i = 0; i < 2000; i++) {
             // Check digit validity (digits must be 0-4)
             if (!isValidDigits(candidate)) {
                 candidate = skipToNextValid(candidate);
                 continue;
             }

             // Calc Hash
             bytes32 hash = keccak256(abi.encodePacked(prevHash, address(challenge), candidate));
             uint256 bal = uint256(hash) % 100 ether;
             
             // Check divisibility by 2 (Dungeon value)
             if (bal % 2 == 0) {
                 targetInv = candidate;
                 targetBal = bal;
                 found = true;
                 // Generate URI
                 targetUri = toEncodedString(candidate);
                 break;
             }
             candidate++;
        }
        require(found, "Could not find valid inventory");
        
        console.log("Target URI:", targetUri);
        console.log("Target Inv Value:", targetInv);
        console.log("Target Balance:", targetBal);

        // 5. Mint Hero
        uint256 tokenId = hero.mint(targetUri);
        
        // 6. Set Quest
        // We need Quest * Dungeon(2) == TargetBal
        quest.setCurrentQuest(targetBal / 2);
        
        // 7. Burn Gold
        // We need exactly targetBal + 1 ether?
        // Or logic: balanceOf(me) must be even? OR match TargetBal?
        // The Revert happened at transferFrom.
        // Let's assume we just need enough gold.
        // But Challenge Logic involves `(gold.balanceOf(entry) - 1 ether) == hash...`?
        // Let's BURN down to exactly `1.0 ether`.
        // Wait, failing `approval` suggests `allowance == inventory`.
        // If `inventory` is 1e18 + delta.
        // `approve(challenge, inventory)`.
        // `mintFlag` calls `transferFrom(..., 1 ether)`.
        // 1 e18 <= inventory. So it works.
        // But what about the HASH check in Challenge?
        // If Challenge checks `balanceOf(me)` against `TargetBal`?
        // Let's set `balance` to `TargetBal + 1 ether` (to cover transfer).
        // Safest bet: Maybe `balance` isn't checked against `TargetBal`.
        // `TargetBal` is likely used for `Inventory` check.
        // Let's keep existing burn logic: Match `targetBal + 1 ether`.
        // If `targetBal` is usually ~50 ether (modulo 100 ether).
        // 1e18 is much larger.
        // Wait. `bal = hash % 100 ether`. Max 100 ether.
        // `inventory` ~ 1 ether.
        // `targetBal` < 100 ether.
        // `currentBalance` ~ 1000 ether.
        // So `currentBalance` > `targetBal`.
        
        uint256 needed = targetBal + 1 ether; 
        if (currentBalance > needed) {
            gold.burn(currentBalance - needed);
        }
        
        // 8. Approve
        // We need allowance to remain equal to targetInv AFTER transferFrom(1 ether) consumes 1 ether.
        gold.approve(address(challenge), targetInv + 1 ether); 
        
        uint256 currentAllowance = gold.allowance(address(this), address(challenge));
        console.log("Current Allowance:", currentAllowance);
        require(currentAllowance == targetInv + 1 ether, "Allowance self-check failed");
        
        // 9. Mint Flag
        challenge.mintFlag(tokenId);
    }

    function isValidDigits(uint256 n) internal pure returns (bool) {
        if (n == 0) return true;
        while (n > 0) {
            if (n % 10 > 4) return false;
            n /= 10;
        }
        return true;
    }
    
    function skipToNextValid(uint256 n) internal pure returns (uint256) {
        // Naive skip: just return n+1 (loop handles check)
        // Optimization: if ends in 5, add 5.
        if (n % 10 >= 5) {
            return n + (10 - (n % 10));
        }
        return n + 1;
    }

    function toEncodedString(uint256 n) internal pure returns (string memory) {
        if (n == 0) return "5";
        bytes memory buffer;
        uint256 temp = n;
        uint256 digits = 0;
        
        // Calculate length (Decimal digits)
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        buffer = new bytes(digits);
        temp = n;
        for (uint256 i = 0; i < digits; i++) {
            uint256 d = temp % 10; // 0..4 assumed checked
            buffer[digits - 1 - i] = bytes1(uint8(d + 0x35)); // '5'..'9'
            temp /= 10;
        }
        return string(buffer);
    }

    function stringToUint(string memory _s) public pure returns (uint256) {
        bytes memory b = bytes(_s);
        uint256 res = 0;
        for (uint i = 0; i < b.length; i++) {
            if (b[i] >= 0x35 && b[i] <= 0x39) { // 0x35='5'
                res = res * 10 + (uint256(uint8(b[i])) - 0x35);
            } else {
                return 0;
            }
        }
        return res;
    }
}
