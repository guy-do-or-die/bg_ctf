// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "../src/IChallenge4.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "forge-std/console.sol";

contract Solve4Script is Script {
    using MessageHashUtils for bytes32;

    function run() external {
        string memory mnemonic = "test test test test test test test test test test test junk";
        uint256 minterKey = vm.deriveKey(mnemonic, 12);
        address minter = vm.addr(minterKey);

        address target = 0x9c4A48Dd70a3219877a252E9a0d45Fc1Db808a1D;
        IChallenge4 challenge = IChallenge4(target);

        console.log("Minter Address defined in S1:", minter);
        console.log("Is Minter:", challenge.isMinter(minter));

        vm.startBroadcast();
        address me = 0x830bc5551e429DDbc4E9Ac78436f8Bf13Eca8434;
        console.log("Sender (Fixed):", me);

        bytes32 message = keccak256(abi.encode("BG CTF Challenge 4", me));
        bytes32 hash = message.toEthSignedMessageHash();

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(minterKey, hash);
        bytes memory signature = abi.encodePacked(r, s, v);

        challenge.mintFlag(minter, signature);

        vm.stopBroadcast();
    }
}
