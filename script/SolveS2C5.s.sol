// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/ISeason2Challenge5.sol";
import "../src/INFTFlags.sol";

contract SolveS2C5 is Script {
    function run() external {
        address target = 0x13f47F26D948AA2A14A7025e5F95A9b815e0BC68;
        address nftAddress = ISeason2Challenge5(target).nftContract();

        vm.startBroadcast();

        uint256 tokenIdCounter = INFTFlags(nftAddress).tokenIdCounter();
        console.log("Token ID Counter:", tokenIdCounter);

        // Requirement 1: mload(add(data1, 0xD0)) == tokenIdCounter
        // 0xD0 = 208.
        // data1 layout:
        // 0x00: length
        // 0x20: element 0
        // ...
        // 0xC0: element 5 (byte 192)
        // 0xE0: element 6 (byte 224)

        // 0xD0 is byte 16 of element 5.
        // Reading 32 bytes from 0xD0 gets:
        // [element 5 lower 16 bytes] [element 6 upper 16 bytes]

        // We want this value to be tokenIdCounter.
        // Assuming tokenIdCounter is small (fits in 16 bytes/128 bits),
        // we set [element 6 upper 16 bytes] to contain tokenIdCounter.
        // element 6 is a uint256. Its layout is big-endian.
        // To put tokenIdCounter in the upper 16 bytes of element 6?

        // Wait, EVM is big endian.
        // Element 6: [byte 0 ... byte 31]
        // We read from element 5 byte 16...31 AND element 6 byte 0...15.
        // So the 32 bytes read are:
        // | E5[16..31] | E6[0..15] |

        // We want this whole thing to equal `tokenIdCounter`.
        // Since `tokenIdCounter` is small (e.g. ~2000), it only occupies the lowest bytes of the resultant 32-bit word.
        // The lowest bytes of the result are E6[15], E6[14]...

        // Result = (E5_lower << 128) | E6_upper
        // We want Result == tokenIdCounter.
        // Since tokenIdCounter < 2^128, E5_lower must be 0.
        // And E6_upper must be `tokenIdCounter`.

        // E6_upper is the top 128 bits of element 6.
        // Element 6 value = (E6_upper << 128) | E6_lower.

        // So we set data1[6] = tokenIdCounter << 128.

        uint256[] memory data1 = new uint256[](7);
        data1[6] = tokenIdCounter << 128;

        // Requirement 2: mload(data2) == tokenIdCounter % 0x80
        // mload(data2) reads the length of the array (at the pointer).
        // So we just need an array of length (tokenIdCounter % 128).
        uint256 len2 = tokenIdCounter % 128;
        uint256[] memory data2 = new uint256[](len2);

        console.log("Data1 Length:", data1.length);
        console.log("Data2 Length:", data2.length);

        ISeason2Challenge5(target).mintFlag(data1, data2);

        vm.stopBroadcast();
    }
}
