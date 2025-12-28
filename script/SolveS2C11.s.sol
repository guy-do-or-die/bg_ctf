// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/RLPEncoder.sol";

interface IS2C11 {
    function preMintFlag() external;
    function mintFlag(bytes memory rlpBytes) external;
    function blockNumber(address) external view returns (uint256);
    function counts(address) external view returns (uint256);
}

contract SolveS2C11 is Script {
    using RLPEncoder for *;

    function run() external {
        address target = 0xae46483c9DC7DAe9FaF971Fe7210bc09AFc304Ff;
        address user = 0x830bc5551e429DDbc4E9Ac78436f8Bf13Eca8434;

        uint256 userBlock = IS2C11(target).blockNumber(user);
        uint256 count = IS2C11(target).counts(user);
        
        console.log("Current Block:", block.number);
        console.log("User Block:", userBlock);
        console.log("User Count:", count);

        vm.startBroadcast();

        if (userBlock == 0 || block.number >= userBlock + 256) {
            console.log("Starting fresh / Resetting window...");
            IS2C11(target).preMintFlag();
        } else if (count < 10) {
            console.log("Pumping count...");
            IS2C11(target).preMintFlag();
        } else {
            uint256 targetBlock = userBlock + 2;
            if (block.number < targetBlock) {
                console.log("Waiting for block to pass...");
                // Do nothing
            } else {
                console.log("Ready to mint! Fetching header for block:", targetBlock);
                bytes memory rlp = getBlockRLP(targetBlock);
                
                // Verify hash
                bytes32 h = keccak256(rlp);
                console.log("Constructed Hash:", uint256(h));
                // Note: We can't verify 'blockhash' of future/recent blocks easily in script if it's too old (256 limit) but we are within 256.
                // Actually, if block.number > targetBlock + 256 we fail. But we checked that above.
                
                IS2C11(target).mintFlag(rlp);
            }
        }

        vm.stopBroadcast();
    }

    function getBlockRLP(uint256 number) internal returns (bytes memory) {
        // Use FFI with cast for robust fetching
        string[] memory inputs = new string[](6);
        inputs[0] = "cast";
        inputs[1] = "block";
        inputs[2] = toHex(number);
        inputs[3] = "--json";
        inputs[4] = "--rpc-url";
        inputs[5] = "https://mainnet.optimism.io";
        
        // Note: Requires --ffi flag
        bytes memory res = vm.ffi(inputs);
        string memory json = string(res);
        console.log("Fetched JSON Length:", bytes(json).length);
        if (bytes(json).length == 0) revert("Empty JSON from ffi");
        
        // Parse fields
        // Standard fields: parentHash, sha3Uncles, miner, stateRoot, transactionsRoot, receiptsRoot, logsBloom, difficulty, number, gasLimit, gasUsed, timestamp, extraData, mixHash, nonce.
        // EIP-1559: baseFeePerGas.
        // Withdrawals? Blob?
        
        bytes[] memory list = new bytes[](16); // Base 15 + baseFee
        
        // Helper to parse JSON bytes32/address/uint
        list[0] = RLPEncoder.encodeBytes(vm.parseJsonBytes(json, ".parentHash"));
        list[1] = RLPEncoder.encodeBytes(vm.parseJsonBytes(json, ".sha3Uncles"));
        list[2] = RLPEncoder.encodeAddress(vm.parseJsonAddress(json, ".miner"));
        list[3] = RLPEncoder.encodeBytes(vm.parseJsonBytes(json, ".stateRoot"));
        list[4] = RLPEncoder.encodeBytes(vm.parseJsonBytes(json, ".transactionsRoot"));
        list[5] = RLPEncoder.encodeBytes(vm.parseJsonBytes(json, ".receiptsRoot"));
        list[6] = RLPEncoder.encodeBytes(vm.parseJsonBytes(json, ".logsBloom"));
        
        // Difficulty is tricky. JSON might return hex string.
        list[7] = RLPEncoder.encodeUint(vm.parseJsonUint(json, ".difficulty"));
        list[8] = RLPEncoder.encodeUint(vm.parseJsonUint(json, ".number"));
        list[9] = RLPEncoder.encodeUint(vm.parseJsonUint(json, ".gasLimit"));
        list[10] = RLPEncoder.encodeUint(vm.parseJsonUint(json, ".gasUsed"));
        list[11] = RLPEncoder.encodeUint(vm.parseJsonUint(json, ".timestamp"));
        
        list[12] = RLPEncoder.encodeBytes(vm.parseJsonBytes(json, ".extraData"));
        list[13] = RLPEncoder.encodeBytes(vm.parseJsonBytes(json, ".mixHash"));
        list[14] = RLPEncoder.encodeBytes(vm.parseJsonBytes(json, ".nonce"));
        
        // BaseFee (EIP-1559)
        // Check if exists? JSON parser throws if missing? 
        // Optimism usually has it.
        // list[15] = RLPEncoder.encodeUint(vm.parseJsonUint(json, ".baseFeePerGas"));
        
        // NOTE: If WithdrawalsRoot exists (Shanghai), it's field 16.
        // If BlobGasUsed exists (Cancun), fields 17, 18, 19.
        // I need to check if keys exist. vm.keyExists?
        // Or just assume standard OP Mainnet structure. 
        // OP Mainnet is Canyon/Delta/Ecotone. Ecotone supports 4844 (Cancun).
        // So we likely have 19/20 fields!
        
        // Dynamic construction logic
        // I'll rebuild the list dynamically.
        
        bytes[] memory dynamicList = new bytes[](25); // Increased max size for safety
        uint count = 15; // Base pre-1559
        
        for(uint i=0; i<15; i++) dynamicList[i] = list[i];
        
        // BaseFee
        if (vm.keyExists(json, ".baseFeePerGas")) {
            dynamicList[count] = RLPEncoder.encodeUint(vm.parseJsonUint(json, ".baseFeePerGas"));
            count++;
        }
        
        // Withdrawals
        if (vm.keyExists(json, ".withdrawalsRoot")) {
            dynamicList[count] = RLPEncoder.encodeBytes(vm.parseJsonBytes(json, ".withdrawalsRoot"));
            count++;
        }
        
        // Cancellations/Blobs?
        if (vm.keyExists(json, ".blobGasUsed")) {
             dynamicList[count] = RLPEncoder.encodeUint(vm.parseJsonUint(json, ".blobGasUsed"));
             count++;
             dynamicList[count] = RLPEncoder.encodeUint(vm.parseJsonUint(json, ".excessBlobGas"));
             count++;
             dynamicList[count] = RLPEncoder.encodeBytes(vm.parseJsonBytes(json, ".parentBeaconBlockRoot"));
             count++;
        }

        // RequestsHash (EIP-7685 / Optimism Isthmus?)
        if (vm.keyExists(json, ".requestsHash")) {
            dynamicList[count] = RLPEncoder.encodeBytes(vm.parseJsonBytes(json, ".requestsHash"));
            count++;
        }
        
        // Copy to correct size
        bytes[] memory finalList = new bytes[](count);
        for(uint k=0; k<count; k++) finalList[k] = dynamicList[k];
        
        return RLPEncoder.encodeList(finalList);
    }
    
    function toHex(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0x0";
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(2 + 64);
        str[0] = "0";
        str[1] = "x";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 16;
        }
        bytes memory result = new bytes(2 + digits);
        result[0] = "0";
        result[1] = "x";
        for (uint256 i = 0; i < digits; i++) {
            result[2 + digits - 1 - i] = alphabet[value % 16];
            value /= 16;
        }
        return string(result);
    }
}
