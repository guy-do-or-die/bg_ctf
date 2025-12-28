// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract IdentifyHashV2 is Script {
    function run() external view {
        address user = 0x830bc5551e429DDbc4E9Ac78436f8Bf13Eca8434;
        address scriptAddr = 0x5b73C5498c1E3b4dbA84de0F1833c4a029d90519; // From trace
        address minter = 0xFABB0ac9d68B0B445fB7357272Ff202C5651694a;

        bytes32 targetDigest = 0xe7232d5eabf55eddf12bae7098638d44a97cfacad4a5caabc93260b2df69b29b;

        console.log("Target:", vm.toString(targetDigest));

        // Target list of addresses to check as "caller"
        address[] memory callers = new address[](3);
        callers[0] = user;
        callers[1] = scriptAddr;
        callers[2] = minter;

        string memory str = "BG CTF Challenge 9";

        for (uint256 i = 0; i < callers.length; i++) {
            address c = callers[i];
            console.log("Checking caller:", c);

            // 1. abi.encode(str, caller)
            check(targetDigest, keccak256(abi.encode(str, c)), "encode(str, caller)");

            // 2. abi.encodePacked(str, caller)
            check(targetDigest, keccak256(abi.encodePacked(str, c)), "packed(str, caller)");

            // 3. abi.encode(caller, str)
            check(targetDigest, keccak256(abi.encode(c, str)), "encode(caller, str)");

            // 4. abi.encodePacked(caller, str)
            check(targetDigest, keccak256(abi.encodePacked(c, str)), "packed(caller, str)");

            // 5. encode(caller)
            check(targetDigest, keccak256(abi.encode(c)), "encode(caller)");

            // 6. encode(str)
            check(targetDigest, keccak256(abi.encode(str)), "encode(str)");
        }
    }

    function check(bytes32 target, bytes32 innerHash, string memory label) internal pure {
        bytes32 ethHash = ECDSA.toEthSignedMessageHash(innerHash);
        if (ethHash == target) {
            console.log("MATCH FOUND:", label);
        }
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
