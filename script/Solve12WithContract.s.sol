// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "../src/Solver12.sol";
import "../src/IChallenge12.sol"; // Ensure this path is correct relative to script folder

contract Solve12WithContract is Script {
    struct BlockHeader {
        bytes32 parentHash;
        bytes32 sha3Uncles;
        address miner;
        bytes32 stateRoot;
        bytes32 transactionsRoot;
        bytes32 receiptsRoot;
        bytes logsBloom;
        uint256 difficulty;
        uint256 number;
        uint256 gasLimit;
        uint256 gasUsed;
        uint256 timestamp;
        bytes extraData;
        bytes32 mixHash;
        uint64 nonce;
        uint256 baseFeePerGas;
        bytes32 withdrawalsRoot;
        uint256 blobGasUsed;
        uint256 excessBlobGas;
        bytes32 parentBeaconBlockRoot;
        bytes32 requestsHash;
    }

    function run() external {
        address target = 0x8c7A3c2c44aB16f693d1731b10C271C7d2967769;
        
        // Deterministic deployment
        bytes32 salt = keccak256("Solve12v2");
        address deployer = 0x4e59b44847b379578588920cA78FbF26c0B4956C; // Deterministic deployer
        
        bytes memory creationCode = abi.encodePacked(
            type(Solver12).creationCode,
            abi.encode(target)
        );
        
        address solverAddr = computeCreate2Address(salt, keccak256(creationCode), deployer);
        console.log("Solver Address:", solverAddr);
        
        uint256 startBlock = IChallenge12(target).blockNumber(solverAddr);
        console.log("Stored Block:", startBlock);
        console.log("Current Block:", block.number);

        vm.startBroadcast();
        
        Solver12 solver;
        if (solverAddr.code.length == 0) {
            console.log("Deploying Solver...");
            solver = new Solver12{salt: salt}(target);
            solver.step1();
            console.log("Deployed & Step 1 executed.");
            vm.stopBroadcast();
            return;
        } else {
            solver = Solver12(solverAddr);
        }
        
        if (startBlock == 0 || block.number > startBlock + 250) {
            console.log("Resetting (Step 1)...");
            solver.step1();
            console.log("Step 1 executed. Wait 2 blocks.");
            vm.stopBroadcast();
            return;
        }
        
        if (block.number < startBlock + 2) {
            console.log("Waiting...");
            vm.stopBroadcast();
            return;
        }
        
        // Execute Step 2
        uint256 targetBlock = startBlock + 2;
        console.log("Executing Step 2 for target block:", targetBlock);
        
        string[] memory cmd = new string[](6);
        cmd[0] = "cast";
        cmd[1] = "block";
        cmd[2] = vm.toString(targetBlock);
        cmd[3] = "--json";
        cmd[4] = "--rpc-url";
        cmd[5] = "https://mainnet.optimism.io";
        
        bytes memory resBytes = vm.ffi(cmd);
        string memory jsonRes = string(resBytes);
        
        BlockHeader memory h;
        h.parentHash = vm.parseJsonBytes32(jsonRes, ".parentHash");
        h.sha3Uncles = vm.parseJsonBytes32(jsonRes, ".sha3Uncles");
        h.miner = vm.parseJsonAddress(jsonRes, ".miner");
        h.stateRoot = vm.parseJsonBytes32(jsonRes, ".stateRoot");
        h.transactionsRoot = vm.parseJsonBytes32(jsonRes, ".transactionsRoot");
        h.receiptsRoot = vm.parseJsonBytes32(jsonRes, ".receiptsRoot");
        h.logsBloom = vm.parseJsonBytes(jsonRes, ".logsBloom");
        h.difficulty = vm.parseJsonUint(jsonRes, ".difficulty");
        h.number = vm.parseJsonUint(jsonRes, ".number");
        h.gasLimit = vm.parseJsonUint(jsonRes, ".gasLimit");
        h.gasUsed = vm.parseJsonUint(jsonRes, ".gasUsed");
        h.timestamp = vm.parseJsonUint(jsonRes, ".timestamp");
        h.extraData = vm.parseJsonBytes(jsonRes, ".extraData");
        h.mixHash = vm.parseJsonBytes32(jsonRes, ".mixHash");
        h.nonce = uint64(vm.parseJsonUint(jsonRes, ".nonce"));
        h.baseFeePerGas = vm.parseJsonUint(jsonRes, ".baseFeePerGas");
        h.withdrawalsRoot = vm.parseJsonBytes32(jsonRes, ".withdrawalsRoot");
        h.blobGasUsed = vm.parseJsonUint(jsonRes, ".blobGasUsed");
        h.excessBlobGas = vm.parseJsonUint(jsonRes, ".excessBlobGas");
        h.parentBeaconBlockRoot = vm.parseJsonBytes32(jsonRes, ".parentBeaconBlockRoot");
        h.requestsHash = vm.parseJsonBytes32(jsonRes, ".requestsHash");

        bytes memory fields = encodeHeader(h);
        bytes memory rlp = abi.encodePacked(encodeListLength(fields.length), fields);
        
        bytes32 myHash = keccak256(rlp);
        bytes32 realHash = vm.parseJsonBytes32(jsonRes, ".hash");
        console.log("Calculated Hash:", vm.toString(myHash));
        console.log("Real Hash:      ", vm.toString(realHash));
        
        if (myHash != realHash) {
            console.log("MISMATCH!");
        }
        
        solver.step2(rlp);
        
        vm.stopBroadcast();
    }

    function encodeHeader(BlockHeader memory h) internal pure returns (bytes memory) {
        bytes memory part1 = abi.encodePacked(
            encodeBytes(abi.encodePacked(h.parentHash)),
            encodeBytes(abi.encodePacked(h.sha3Uncles)),
            encodeBytes(abi.encodePacked(h.miner)),
            encodeBytes(abi.encodePacked(h.stateRoot)),
            encodeBytes(abi.encodePacked(h.transactionsRoot))
        );
        
        bytes memory part2 = abi.encodePacked(
            encodeBytes(abi.encodePacked(h.receiptsRoot)),
            encodeBytes(h.logsBloom),
            encodeUint(h.difficulty),
            encodeUint(h.number),
            encodeUint(h.gasLimit)
        );
        
        bytes memory part3 = abi.encodePacked(
            encodeUint(h.gasUsed),
            encodeUint(h.timestamp),
            encodeBytes(h.extraData),
            encodeBytes(abi.encodePacked(h.mixHash)),
            encodeBytes(abi.encodePacked(bytes8(h.nonce)))
        );
        
        bytes memory part4 = abi.encodePacked(
            encodeUint(h.baseFeePerGas),
            encodeBytes(abi.encodePacked(h.withdrawalsRoot)),
            encodeUint(h.blobGasUsed),
            encodeUint(h.excessBlobGas),
            encodeBytes(abi.encodePacked(h.parentBeaconBlockRoot)),
            encodeBytes(abi.encodePacked(h.requestsHash))
        );

        return abi.encodePacked(part1, part2, part3, part4);
    }
    
    // RLP Encoding Helpers
    function encodeListLength(uint256 len) internal pure returns (bytes memory) {
         if (len <= 55) {
            return abi.encodePacked(uint8(0xc0 + len));
        } else {
            bytes memory bLength = toBytes(len);
            return abi.encodePacked(uint8(0xf7 + bLength.length), bLength);
        }
    }
    function encodeUint(uint256 x) internal pure returns (bytes memory) {
        if (x == 0) return hex"80";
        else if (x < 128) return abi.encodePacked(uint8(x));
        else {
            bytes memory b = toBytes(x);
            return abi.encodePacked(uint8(0x80 + b.length), b);
        }
    }

    function encodeBytes(bytes memory d) internal pure returns (bytes memory) {
        if (d.length == 1 && uint8(d[0]) < 128) {
            return d;
        } else if (d.length <= 55) {
            return abi.encodePacked(uint8(0x80 + d.length), d);
        } else {
            bytes memory bLength = toBytes(d.length);
            return abi.encodePacked(uint8(0xb7 + bLength.length), bLength, d);
        }
    }
    
    function toBytes(uint256 x) internal pure returns (bytes memory b) {
        b = new bytes(32);
        assembly { mstore(add(b, 32), x) }
        
        uint256 i;
        for (i = 0; i < 32; i++) {
            if (b[i] != 0) break;
        }
        
        uint256 len = 32 - i;
        bytes memory res = new bytes(len);
        for (uint256 j = 0; j < len; j++) {
            res[j] = b[i + j];
        }
        return res;
    }
}
