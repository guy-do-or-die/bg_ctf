// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract DebugS2C9Verify is Script {
    function run() external {
        address target = 0x3f7aF25E3Fb83789a8f63c4f3292F96763cd3D12;
        address minter = 0xFABB0ac9d68B0B445fB7357272Ff202C5651694a;

        vm.startBroadcast();

        // 1. Check storage slot 2 (stor2) for minter
        bytes32 slot = keccak256(abi.encode(minter, uint256(2)));
        bytes32 val = vm.load(target, slot);
        console.log("Storage Slot 2 Value for Minter:", uint256(val));

        if (uint256(val) != 0) {
            console.log("Confirmed: Address is a minter in Slot 2.");
        } else {
            console.log("WARNING: Address is NOT a minter in Slot 2.");
        }

        // 2. Call with dummy signature to provoke error
        bytes memory dummySig = new bytes(65);
        (bool success, bytes memory ret) = target.call(abi.encodeWithSelector(0x23cfec7e, minter, dummySig));

        if (!success) {
            if (ret.length > 0) {
                console.log("Revert Reason:", string(ret));
                // Try decoding plain string error
                try this.decodeError(ret) returns (string memory s) {
                    console.log("Decoded String:", s);
                } catch {
                    console.log("Could not decode string");
                }
            } else {
                console.log("Revert with NO DATA");
            }
        } else {
            console.log("Unexpected Success with dummy sig?");
        }

        vm.stopBroadcast();
    }

    function decodeError(bytes memory data) public pure returns (string memory) {
        // Skip selector if present (0x08c379a0)
        if (data.length >= 4 && bytes4(data) == 0x08c379a0) {
            return abi.decode(slice(data, 4), (string));
        }
        return string(data);
    }

    function slice(bytes memory _bytes, uint256 _start) internal pure returns (bytes memory) {
        require(_bytes.length >= _start, "Slice out of bounds");
        uint256 _length = _bytes.length - _start;
        bytes memory _tempBytes = new bytes(_length);
        for (uint256 i = 0; i < _length; i++) {
            _tempBytes[i] = _bytes[i + _start];
        }
        return _tempBytes;
    }
}
