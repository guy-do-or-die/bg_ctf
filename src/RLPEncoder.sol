// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

library RLPEncoder {
    function encodeTransaction(bytes memory item) internal pure returns (bytes memory) {
        // Simple wrapper if needed, but we focus on header fields
        return encodeBytes(item);
    }
    
    function encodeList(bytes[] memory items) internal pure returns (bytes memory) {
        bytes memory payload;
        for (uint i = 0; i < items.length; i++) {
            payload = abi.encodePacked(payload, items[i]);
        }
        return encodeHeader(payload.length, 0xC0, payload);
    }

    function encodeString(string memory self) internal pure returns (bytes memory) {
        return encodeBytes(bytes(self));
    }

    function encodeAddress(address self) internal pure returns (bytes memory) {
        return encodeBytes(abi.encodePacked(self));
    }

    function encodeUint(uint self) internal pure returns (bytes memory) {
        if (self == 0) {
            return hex"80";
        } else if (self < 0x80) {
            return abi.encodePacked(uint8(self));
        } else {
            bytes memory b = toBinary(self);
            return encodeHeader(b.length, 0x80, b);
        }
    }

    function encodeBytes(bytes memory self) internal pure returns (bytes memory) {
        if (self.length == 1 && uint8(self[0]) < 0x80) {
            return self;
        } else {
            return encodeHeader(self.length, 0x80, self);
        }
    }

    function encodeHeader(uint len, uint8 offset, bytes memory data) internal pure returns (bytes memory) {
        if (len < 56) {
            return abi.encodePacked(uint8(offset + len), data);
        } else {
            bytes memory lenBytes = toBinary(len);
            return abi.encodePacked(uint8(offset + 55 + lenBytes.length), lenBytes, data);
        }
    }

    function toBinary(uint x) internal pure returns (bytes memory) {
        if (x == 0) {
            return new bytes(0);
        }
        bytes memory b = new bytes(32);
        assembly { mstore(add(b, 32), x) }
        uint i;
        for (i = 0; i < 32; i++) {
            if (b[i] != 0) {
                break;
            }
        }
        bytes memory res = new bytes(32 - i);
        for (uint j = 0; j < res.length; j++) {
            res[j] = b[i + j];
        }
        return res;
    }
}
