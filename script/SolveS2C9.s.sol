// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract SolveS2C9 is Script {
    function run() external {
        address target = 0x3f7aF25E3Fb83789a8f63c4f3292F96763cd3D12;
        // User EOA. This must match the sender used in --sender flag.
        address user = 0x830bc5551e429DDbc4E9Ac78436f8Bf13Eca8434;

        string memory mnemonic = "test test test test test test test test test test test junk";
        uint32 index = 12;

        uint256 minterPrivateKey = vm.deriveKey(mnemonic, index);
        address minterAddress = vm.addr(minterPrivateKey);

        console.log("Derived Minter:", minterAddress);
        console.log("User/Signer:", user);

        // 1. Construct hash for the USER (who will call the contract)
        // IdentifyHashV2 confirmed: keccak256(abi.encode(str, caller))
        bytes32 innerHash = keccak256(abi.encode("BG CTF Challenge 9", user));
        bytes32 ethSignedHash = ECDSA.toEthSignedMessageHash(innerHash);

        // 2. Sign
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(minterPrivateKey, ethSignedHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        // 3. Verify locally
        address recovered = ecrecover(ethSignedHash, v, r, s);
        require(recovered == minterAddress, "Local recovery failed");
        console.log("Signature valid locally for user:", user);

        vm.startBroadcast();

        // 4. Call directly
        // Ensure we are using the low-level call to get the exact selector
        // The contract will compute hash("BG...", msg.sender) -> hash("BG...", user)
        // And compare ecrecover(hash, sig) == minter.
        (bool success, bytes memory ret) = target.call(abi.encodeWithSelector(0x23cfec7e, minterAddress, signature));

        if (!success) {
            console.log("Call failed. Revert data:", string(ret));
        } else {
            console.log("SUCCESS! Flag should be minted.");
        }

        vm.stopBroadcast();
    }
}

library ECDSA {
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}
