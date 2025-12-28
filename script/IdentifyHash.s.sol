// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract IdentifyHash is Script {
    function run() external view {
        address user = 0x830bc5551e429DDbc4E9Ac78436f8Bf13Eca8434;
        bytes32 targetDigest = 0xe7232d5eabf55eddf12bae7098638d44a97cfacad4a5caabc93260b2df69b29b;

        console.log("Target Digest:", vm.toString(targetDigest));

        // 1. abi.encode
        check(targetDigest, keccak256(abi.encode("BG CTF Challenge 9", user)), "abi.encode(str, user)");

        // 2. abi.encodePacked
        check(targetDigest, keccak256(abi.encodePacked("BG CTF Challenge 9", user)), "abi.encodePacked(str, user)");

        // 3. String Double Hash
        check(
            targetDigest, keccak256(abi.encodePacked(keccak256("BG CTF Challenge 9"), user)), "packed(sha3(str), user)"
        );
        check(targetDigest, keccak256(abi.encode(keccak256("BG CTF Challenge 9"), user)), "encode(sha3(str), user)");

        // 4. Minter address included?
        address minter = 0xFABB0ac9d68B0B445fB7357272Ff202C5651694a;
        check(targetDigest, keccak256(abi.encode("BG CTF Challenge 9", user, minter)), "encode(str, user, minter)");
    }

    function check(bytes32 target, bytes32 innerHash, string memory label) internal pure {
        bytes32 ethHash = ECDSA.toEthSignedMessageHash(innerHash);
        if (ethHash == target) {
            console.log("MATCH FOUND:", label);
        } else {
            // console.log(label, vm.toString(innerHash)); // Only print matches or specific debugging
        }

        // Also check if innerHash matches target (no prefix)
        if (innerHash == target) {
            console.log("MATCH FOUND (RAW):", label);
        }
    }
}

library ECDSA {
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}
